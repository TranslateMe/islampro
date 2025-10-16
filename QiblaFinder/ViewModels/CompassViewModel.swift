import Foundation
import SwiftUI
import CoreLocation
import Combine

/// ViewModel that combines LocationManager, CompassManager, and QiblaCalculator
/// Provides unified, observable data for the compass UI
class CompassViewModel: ObservableObject {

    // MARK: - Published Properties (UI observes these)

    // Location
    @Published var userLocation: CLLocation?
    @Published var locationError: String?

    // Qibla Direction
    @Published var qiblaDirection: QiblaDirection?
    @Published var relativeBearing: Double = 0.0  // -180 to +180 for compass needle rotation

    // Compass
    @Published var deviceHeading: Double = 0.0
    @Published var isCalibrated: Bool = false
    @Published var calibrationAccuracy: Int = -1
    @Published var compassError: String?

    // UI State
    @Published var isLoading: Bool = true
    @Published var showCalibrationPrompt: Bool = false

    // MARK: - Private Properties

    private let locationManager = LocationManager.shared
    private let compassManager = CompassManager.shared
    private let hapticManager = HapticManager.shared
    private var cancellables = Set<AnyCancellable>()

    // Track previous alignment state for haptic feedback
    // Triggers haptic ONLY when alignment achieved (false → true)
    // Does NOT trigger when alignment lost (respectful, not annoying)
    private var previousAlignment: Bool = false

    // MARK: - Computed Properties

    /// Whether device is aligned with Qibla (within 5° threshold)
    var isAligned: Bool {
        guard qiblaDirection != nil else { return false }
        return abs(relativeBearing) <= Constants.QIBLA_ALIGNMENT_THRESHOLD
    }

    /// Formatted distance to Mecca (e.g., "10,742 km")
    var distanceToMecca: String {
        qiblaDirection?.formattedDistance ?? "--"
    }

    /// Formatted bearing text (e.g., "58° NE")
    var bearingText: String {
        qiblaDirection?.formattedBearing ?? "--"
    }

    /// Calibration indicator color (traffic light system)
    /// - Green: High accuracy (calibration level 2)
    /// - Yellow: Medium accuracy (calibration level 1)
    /// - Red: Low/uncalibrated (calibration level 0 or invalid)
    /// - Gray: Compass unavailable (simulator/no hardware)
    var calibrationColor: Color {
        // Edge case: Compass not available on device (simulator)
        guard compassManager.isAvailable else {
            return .gray
        }

        switch calibrationAccuracy {
        case 2: return .green                    // High accuracy (≤ 5°) - calibrated
        case 1: return Color(hex: "#FFC107")     // Medium accuracy (≤ 15°) - usable
        default: return .red                     // Low/invalid accuracy - needs calibration
        }
    }

    /// Whether to show first-time calibration prompt
    /// Only shows when accuracy is low AND user hasn't seen it before
    /// Progressive disclosure: educate once, then get out of the way
    private var hasSeenCalibrationPrompt: Bool {
        get { UserDefaults.standard.bool(forKey: "hasSeenCalibrationPrompt") }
        set { UserDefaults.standard.set(newValue, forKey: "hasSeenCalibrationPrompt") }
    }

    /// Location status for UI display
    var locationStatus: String {
        if let error = locationError {
            return error
        }

        if locationManager.authorizationStatus == .notDetermined {
            return "Location permission required"
        }

        if locationManager.authorizationStatus == .denied {
            return "Location permission denied"
        }

        if userLocation == nil {
            return "Locating..."
        }

        return "Location found"
    }

    /// Compass status for UI display
    var compassStatus: String {
        if let error = compassError {
            return error
        }

        if !compassManager.isAvailable {
            return "Compass not available"
        }

        if calibrationAccuracy < 1 {
            return "Calibrating..."
        }

        if calibrationAccuracy == 1 {
            return "Compass ready"
        }

        return "High accuracy"
    }

    // MARK: - Initialization

    init() {
        setupBindings()
    }

    // MARK: - Public Methods

    /// Start compass and location updates
    /// Should be called in View's .onAppear
    func startCompass() {
        compassManager.startUpdating()

        // Location manager auto-starts when permission is granted
        // But we can request a fresh location update
        if locationManager.authorizationStatus == .authorizedWhenInUse ||
           locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }

        // Prepare haptic generator for immediate response
        // Battery-optimized: prepared on demand, released on disappear
        hapticManager.prepare()
    }

    /// Stop compass updates to save battery
    /// Should be called in View's .onDisappear
    func stopCompass() {
        compassManager.stopUpdating()
        // Keep location running at low frequency for background updates

        // Release haptic generator to save battery
        hapticManager.release()
    }

    // MARK: - Private Methods

    /// Set up Combine subscriptions to observe managers
    private func setupBindings() {
        // Subscribe to location updates
        locationManager.$currentLocation
            .sink { [weak self] location in
                self?.handleLocationUpdate(location)
            }
            .store(in: &cancellables)

        // Subscribe to location errors
        locationManager.$error
            .sink { [weak self] error in
                self?.locationError = error?.localizedDescription
            }
            .store(in: &cancellables)

        // Subscribe to heading updates
        compassManager.$heading
            .sink { [weak self] heading in
                self?.handleHeadingUpdate(heading)
            }
            .store(in: &cancellables)

        // Subscribe to calibration status
        compassManager.$isCalibrated
            .assign(to: &$isCalibrated)

        compassManager.$calibrationAccuracy
            .sink { [weak self] accuracy in
                guard let self = self else { return }
                self.calibrationAccuracy = accuracy

                // Show calibration prompt ONLY if:
                // 1. Accuracy is low (< 1)
                // 2. User hasn't seen the prompt before (first time)
                // Progressive disclosure: educate once, then get out of the way
                if accuracy < 1 && !self.hasSeenCalibrationPrompt {
                    self.showCalibrationPrompt = true
                    // Mark as seen after 10 seconds (user has seen it)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self.hasSeenCalibrationPrompt = true
                    }
                } else if accuracy >= 1 {
                    // Hide prompt when accuracy improves (immediate reward feedback)
                    self.showCalibrationPrompt = false
                    if !self.hasSeenCalibrationPrompt {
                        self.hasSeenCalibrationPrompt = true
                    }
                }
            }
            .store(in: &cancellables)

        // Subscribe to compass errors
        compassManager.$error
            .sink { [weak self] error in
                self?.compassError = error?.localizedDescription
            }
            .store(in: &cancellables)

        // Combine location + heading to calculate Qibla direction
        // This is the heart of the reactive system
        Publishers.CombineLatest(
            locationManager.$currentLocation,
            compassManager.$heading
        )
        .sink { [weak self] location, heading in
            self?.updateQiblaDirection(location: location, heading: heading)
        }
        .store(in: &cancellables)
    }

    /// Handle location updates
    private func handleLocationUpdate(_ location: CLLocation?) {
        userLocation = location

        // Stop loading once we have location
        if location != nil {
            isLoading = false
        }
    }

    /// Handle heading updates
    private func handleHeadingUpdate(_ heading: Double) {
        deviceHeading = heading
    }

    /// Update Qibla direction when location or heading changes
    /// This is called automatically via Combine whenever either value updates
    private func updateQiblaDirection(location: CLLocation?, heading: Double) {
        guard let location = location else {
            qiblaDirection = nil
            relativeBearing = 0.0
            previousAlignment = false  // Reset when no location
            return
        }

        // Calculate Qibla direction from user location
        let qibla = QiblaCalculator.calculateQibla(from: location)
        qiblaDirection = qibla

        // Calculate relative bearing for compass needle rotation
        // Returns -180 to +180 where 0 = pointing at Mecca
        relativeBearing = compassManager.calculateQiblaDirection(from: location)

        // Trigger haptic feedback when alignment achieved (false → true only)
        // Multimodal feedback: visual glow + VoiceOver + haptic
        let currentAlignment = isAligned
        if !previousAlignment && currentAlignment {
            // Alignment achieved! Trigger haptic confirmation
            hapticManager.triggerAlignment()
        }

        // Update previous state for next check
        previousAlignment = currentAlignment
    }
}
