import Foundation
import CoreLocation
import Combine

/// Manages device compass heading using CoreLocation's magnetometer
/// Provides real-time heading updates for Qibla direction calculation
class CompassManager: NSObject, ObservableObject {

    // MARK: - Published Properties

    /// Current device heading in degrees (0-360°, 0° = North, 90° = East, 180° = South, 270° = West)
    /// Uses true heading (corrected for magnetic declination) when location is available
    @Published var heading: Double = 0.0

    /// Whether the compass is calibrated (accuracy is acceptable)
    @Published var isCalibrated: Bool = false

    /// Calibration accuracy level: -1 (invalid), 0 (low), 1 (medium), 2 (high)
    @Published var calibrationAccuracy: Int = -1

    /// Whether compass hardware is available on device
    @Published var isAvailable: Bool = false

    /// Current error state, if any
    @Published var error: CompassError?

    // MARK: - Private Properties

    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Singleton

    static let shared = CompassManager()

    // MARK: - Error Types

    enum CompassError: Error, LocalizedError {
        case notAvailable
        case calibrationRequired
        case headingUnavailable

        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Compass not available on this device"
            case .calibrationRequired:
                return "Compass calibration required"
            case .headingUnavailable:
                return "Unable to determine heading"
            }
        }
    }

    // MARK: - Initialization

    private override init() {
        super.init()
        locationManager.delegate = self

        // Set heading filter for smooth updates (1° = very responsive)
        // Lower values = more frequent updates, smoother animation
        locationManager.headingFilter = 1.0

        // Check if heading is available
        isAvailable = CLLocationManager.headingAvailable()

        if !isAvailable {
            error = .notAvailable
        }
    }

    // MARK: - Public Methods

    /// Start receiving compass heading updates
    /// Should be called when app becomes active
    func startUpdating() {
        guard isAvailable else {
            error = .notAvailable
            return
        }

        locationManager.startUpdatingHeading()
        error = nil
    }

    /// Stop receiving compass heading updates
    /// Should be called when app goes to background to save battery
    func stopUpdating() {
        locationManager.stopUpdatingHeading()
    }

    /// Calculate Qibla direction relative to device heading
    /// - Parameter location: User's current location
    /// - Returns: Relative angle in degrees (-180 to +180) where 0° = device pointing at Mecca
    ///
    /// Example: If Qibla is 58° (NE) and device heading is 30° (facing NNE),
    /// result is +28°, meaning turn right 28° to face Mecca
    func calculateQiblaDirection(from location: CLLocation) -> Double {
        let qiblaDirection = QiblaCalculator.calculateQibla(from: location)
        let relativeBearing = qiblaDirection.bearing - heading

        // Normalize to -180 to +180 range for intuitive display
        return normalizeAngle(relativeBearing)
    }

    /// Get full QiblaDirection data for UI display
    /// - Parameter location: User's current location
    /// - Returns: Complete QiblaDirection with bearing, distance, etc.
    func getQiblaDirection(from location: CLLocation) -> QiblaDirection {
        return QiblaCalculator.calculateQibla(from: location)
    }

    // MARK: - Private Methods

    /// Normalize angle to -180 to +180 range
    /// This makes it easier to show "turn left/right X degrees"
    private func normalizeAngle(_ angle: Double) -> Double {
        var normalized = angle

        // Wrap to 0-360 range first
        while normalized > 360 {
            normalized -= 360
        }
        while normalized < 0 {
            normalized += 360
        }

        // Convert to -180 to +180
        if normalized > 180 {
            normalized -= 360
        }

        return normalized
    }

    /// Determine calibration status from heading accuracy
    /// - Parameter accuracy: CLLocationDirection (degrees)
    /// - Returns: Calibration level (0 = low, 1 = medium, 2 = high)
    private func calibrationLevel(from accuracy: CLLocationDirection) -> Int {
        if accuracy < 0 {
            return -1 // Invalid
        } else if accuracy <= 5 {
            return 2 // High accuracy (within 5°)
        } else if accuracy <= 15 {
            return 1 // Medium accuracy (within 15°)
        } else {
            return 0 // Low accuracy (> 15°)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension CompassManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Prefer true heading (corrected for magnetic declination) when available
        // True heading is -1 when it can't be calculated (no location data)
        let newHeadingValue: Double

        if newHeading.trueHeading >= 0 {
            // True heading available (requires location for magnetic declination)
            newHeadingValue = newHeading.trueHeading
        } else {
            // Fall back to magnetic heading
            newHeadingValue = newHeading.magneticHeading
        }

        // Update heading
        heading = newHeadingValue

        // Update calibration status
        let accuracy = newHeading.headingAccuracy
        calibrationAccuracy = calibrationLevel(from: accuracy)

        // Consider calibrated if accuracy is medium or high (< 15°)
        isCalibrated = calibrationAccuracy >= 1

        // Clear any previous errors
        error = nil

        // Show calibration warning if accuracy is low
        if calibrationAccuracy == 0 {
            error = .calibrationRequired
        }
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        // Return true to allow iOS to show calibration screen when needed
        // iOS will automatically prompt user to calibrate by moving device in figure-8 pattern
        return true
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Only handle heading-related errors
        if let clError = error as? CLError {
            switch clError.code {
            case .headingFailure:
                self.error = .headingUnavailable
            default:
                // Other errors are handled by LocationManager
                break
            }
        }
    }
}
