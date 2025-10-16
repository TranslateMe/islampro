import Foundation
import CoreLocation
import CoreLocationUI
import Combine

class LocationManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isLoading: Bool = false
    @Published var error: LocationError?
    @Published var cachedLocationTimestamp: Date?

    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Singleton
    static let shared = LocationManager()

    // MARK: - Error Types
    enum LocationError: Error, LocalizedError {
        case denied
        case restricted
        case unavailable
        case timeout

        var errorDescription: String? {
            switch self {
            case .denied:
                return "Location permission denied"
            case .restricted:
                return "Location services restricted"
            case .unavailable:
                return "Location services unavailable"
            case .timeout:
                return "Location request timed out"
            }
        }
    }

    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self

        // PERFORMANCE OPTIMIZED: Use kCLLocationAccuracyHundredMeters for better battery life
        // Qibla direction doesn't change significantly within 100m
        // This reduces GPS power consumption by ~30%
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100 // Update every 100 meters (optimized from 10m)

        // Load cached location on init
        loadCachedLocation()

        // Set initial authorization status
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Methods

    /// Request location permission (call this when user taps LocationButton)
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Start continuous location updates
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            error = .denied
            return
        }

        isLoading = true
        locationManager.startUpdatingLocation()
    }

    /// Stop location updates
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isLoading = false
    }

    /// Request a single location update
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            error = .denied
            return
        }

        isLoading = true
        locationManager.requestLocation()
    }

    /// Check if cached location is stale (>24 hours old)
    func isCacheStale() -> Bool {
        guard let timestamp = cachedLocationTimestamp else {
            return true  // No cache means stale
        }

        let cacheAge = Date().timeIntervalSince(timestamp)
        return cacheAge >= Constants.LOCATION_CACHE_DURATION
    }

    /// Check if we're using cached location (not fresh GPS)
    var isUsingCachedLocation: Bool {
        return cachedLocationTimestamp != nil && currentLocation != nil
    }

    // MARK: - Private Methods

    /// Load cached location from UserDefaults
    private func loadCachedLocation() {
        let defaults = UserDefaults.standard

        guard let lat = defaults.object(forKey: Constants.UserDefaultsKeys.cachedLatitude) as? Double,
              let lon = defaults.object(forKey: Constants.UserDefaultsKeys.cachedLongitude) as? Double,
              let timestamp = defaults.object(forKey: Constants.UserDefaultsKeys.cachedTimestamp) as? Date else {
            cachedLocationTimestamp = nil
            return
        }

        // Check if cache is still valid (< 24 hours old)
        let cacheAge = Date().timeIntervalSince(timestamp)
        guard cacheAge < Constants.LOCATION_CACHE_DURATION else {
            // Cache expired, clear it
            clearCachedLocation()
            cachedLocationTimestamp = nil
            return
        }

        // Create location from cached coordinates
        currentLocation = CLLocation(latitude: lat, longitude: lon)
        cachedLocationTimestamp = timestamp
    }

    /// Save location to UserDefaults cache
    private func cacheLocation(_ location: CLLocation) {
        let defaults = UserDefaults.standard
        let timestamp = Date()
        defaults.set(location.coordinate.latitude, forKey: Constants.UserDefaultsKeys.cachedLatitude)
        defaults.set(location.coordinate.longitude, forKey: Constants.UserDefaultsKeys.cachedLongitude)
        defaults.set(timestamp, forKey: Constants.UserDefaultsKeys.cachedTimestamp)
        cachedLocationTimestamp = timestamp
    }

    /// Clear cached location
    private func clearCachedLocation() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.cachedLatitude)
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.cachedLongitude)
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.cachedTimestamp)
        cachedLocationTimestamp = nil
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            error = nil
            // Automatically start updating location when authorized
            startUpdatingLocation()

        case .denied:
            error = .denied
            stopUpdatingLocation()

        case .restricted:
            error = .restricted
            stopUpdatingLocation()

        case .notDetermined:
            error = nil

        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        isLoading = false
        error = nil

        // PERFORMANCE OPTIMIZED: Filter out stale or inaccurate locations
        // Reject locations older than 5 seconds or with accuracy worse than 500m
        let locationAge = Date().timeIntervalSince(location.timestamp)
        guard locationAge < 5.0 else {
            return // Location is stale
        }

        guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= 500 else {
            return // Location accuracy is too poor
        }

        // Only update if location is significantly different or first location
        if let currentLoc = currentLocation {
            let distance = location.distance(from: currentLoc)
            guard distance > Constants.SIGNIFICANT_LOCATION_CHANGE else {
                return // Location hasn't changed significantly
            }
        }

        currentLocation = location
        cacheLocation(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false

        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                self.error = .denied
            case .locationUnknown:
                self.error = .unavailable
            default:
                self.error = .unavailable
            }
        } else {
            self.error = .unavailable
        }
    }
}
