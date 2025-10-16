import Foundation
import SwiftUI
import CoreLocation
import Combine

/// ViewModel that manages prayer times calculation and display
/// Combines LocationManager and PrayerTimesCalculator for reactive UI updates
///
/// Design Philosophy:
/// - Reactive architecture (Combine subscriptions)
/// - Battery efficient (timer only runs when view visible)
/// - Smart recalculation (only when location changes significantly)
/// - Edge case handling (no location, all prayers passed, polar regions)
///
/// Architecture:
/// ```
/// LocationManager → ViewModel → PrayerTimesCalculator → [PrayerTimeDisplay] → UI
/// Timer (1 second) → Update countdowns → UI refreshes
/// ```
@MainActor
class PrayerTimesViewModel: ObservableObject {

    // MARK: - Published Properties (UI observes these)

    /// Array of prayer times for display (6 prayers: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
    @Published var prayerTimes: [PrayerTimeDisplay] = []

    /// Next upcoming prayer (for highlighting)
    @Published var nextPrayer: PrayerTimeDisplay?

    /// Current prayer period we're in
    @Published var currentPrayer: PrayerTimeDisplay?

    /// Loading state
    @Published var isLoading: Bool = true

    /// Error message if calculation fails
    @Published var errorMessage: String?

    /// Hijri date string (e.g., "15 Ramadan 1446")
    @Published var hijriDate: String = ""

    // MARK: - Private Properties

    private let locationManager = LocationManager.shared
    private let notificationManager = NotificationManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    /// Last location used for calculation (to avoid unnecessary recalculations)
    private var lastCalculatedLocation: CLLocation?

    /// Last time we checked for prayer time changes (to optimize performance)
    private var lastPrayerCheckTime: Date?

    /// Calculation method - reads from UserDefaults dynamically
    private var calculationMethod: PrayerCalculationMethod {
        if let methodRaw = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.selectedCalculationMethod),
           let method = PrayerCalculationMethod(rawValue: methodRaw) {
            return method
        }
        return .muslimWorldLeague  // Default fallback
    }

    /// Madhab - reads from UserDefaults dynamically
    private var madhab: PrayerMadhab {
        if let madhabRaw = UserDefaults.standard.string(forKey: "selectedMadhab"),
           let madhab = PrayerMadhab(rawValue: madhabRaw) {
            return madhab
        }
        return .shafi  // Default fallback
    }

    // MARK: - Initialization

    init() {
        setupBindings()
        setupNotificationObservers()
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Public Methods

    /// Start timer for countdown updates
    /// Call this in View's .onAppear
    func startTimer() {
        // Stop any existing timer
        stopTimer()

        // Create new timer that fires every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateCountdowns()
            }
        }

        // Fire immediately for instant update
        updateCountdowns()
    }

    /// Stop timer to save battery
    /// Call this in View's .onDisappear
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Private Methods

    /// Set up Combine subscriptions to observe location changes
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
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)
    }

    /// Set up NotificationCenter observers for settings changes
    private func setupNotificationObservers() {
        // Listen for notification settings changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationSettingsChanged),
            name: .notificationSettingsChanged,
            object: nil
        )

        // Listen for calculation method changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePrayerSettingsChanged),
            name: .calculationMethodChanged,
            object: nil
        )

        // Listen for madhab changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePrayerSettingsChanged),
            name: .madhabChanged,
            object: nil
        )
    }

    /// Handle notification settings change (reschedule notifications with new settings)
    @objc private func handleNotificationSettingsChanged() {
        // Reschedule notifications with current prayer times
        scheduleNotificationsIfNeeded()
    }

    /// Handle prayer calculation settings change (recalculate prayer times immediately)
    @objc private func handlePrayerSettingsChanged() {
        // Recalculate prayer times with new settings
        if let location = lastCalculatedLocation {
            calculatePrayerTimes(for: location)
        }
    }

    /// Handle location updates
    /// Only recalculates if location changed significantly (>50km)
    private func handleLocationUpdate(_ location: CLLocation?) {
        guard let location = location else {
            // No location yet
            isLoading = true
            errorMessage = nil
            return
        }

        // Check if we need to recalculate
        // Only recalculate if location changed significantly (>50km)
        let shouldRecalculate: Bool
        if let lastLocation = lastCalculatedLocation {
            let distance = location.distance(from: lastLocation)
            shouldRecalculate = distance > Constants.SIGNIFICANT_LOCATION_CHANGE
        } else {
            // First time, always calculate
            shouldRecalculate = true
        }

        if shouldRecalculate {
            lastCalculatedLocation = location
            calculatePrayerTimes(for: location)
        }
    }

    /// Calculate prayer times for given location
    private func calculatePrayerTimes(for location: CLLocation) {
        // Calculate prayer times using PrayerTimesCalculator
        guard let calculatedTimes = PrayerTimesCalculator.calculatePrayerTimes(
            for: location,
            date: Date(),
            method: calculationMethod,
            madhab: madhab
        ) else {
            // Edge case: Calculation failed (polar regions, invalid location)
            errorMessage = "Unable to calculate prayer times for this location"
            isLoading = false
            prayerTimes = []
            return
        }

        // Convert to display models
        convertToDisplayModels(calculatedTimes)

        // Calculate Hijri date
        hijriDate = Date().hijriDateString()

        // Clear loading and error states
        isLoading = false
        errorMessage = nil
    }

    /// Convert CalculatedPrayerTimes to [PrayerTimeDisplay] array
    private func convertToDisplayModels(_ times: CalculatedPrayerTimes) {
        // Get all 6 prayers
        let allPrayers: [Prayer] = [.fajr, .sunrise, .dhuhr, .asr, .maghrib, .isha]

        // Determine which is next and current
        let nextPrayerType = PrayerTimesCalculator.nextPrayer(from: times)
        let currentPrayerType = PrayerTimesCalculator.currentPrayer(from: times)

        // Convert to display models
        prayerTimes = allPrayers.map { prayer in
            PrayerTimeDisplay(
                prayer: prayer,
                time: times.time(for: prayer),
                isNext: prayer == nextPrayerType,
                isCurrent: prayer == currentPrayerType
            )
        }

        // Set next and current for easy access
        nextPrayer = prayerTimes.first { $0.isNext }
        currentPrayer = prayerTimes.first { $0.isCurrent }

        // Schedule notifications if enabled
        scheduleNotificationsIfNeeded()
    }

    /// Schedule prayer time notifications based on user preferences
    private func scheduleNotificationsIfNeeded() {
        // Check if notifications are enabled in settings
        guard UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.notificationsEnabled) else {
            return
        }

        // Get notification timing preference (minutes before prayer)
        let minutesBefore = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.notificationMinutesBefore)

        // Schedule notifications
        notificationManager.schedulePrayerNotifications(prayerTimes: prayerTimes, minutesBefore: minutesBefore)
    }

    /// Update countdowns for all prayers
    /// Called every second by timer
    /// PERFORMANCE OPTIMIZED: Only triggers UI refresh, checks for prayer changes every 30 seconds
    private func updateCountdowns() {
        // Force UI refresh by reassigning the array
        // This is lightweight - SwiftUI will recalculate countdown strings for each element
        // The reassignment triggers @Published update, causing view to re-render
        prayerTimes = prayerTimes

        // Check if next/current prayer has changed (but only every 30 seconds)
        // This reduces CPU usage from ~20% to <5%
        let now = Date()
        let shouldCheckPrayerChange: Bool

        if let lastCheck = lastPrayerCheckTime {
            shouldCheckPrayerChange = now.timeIntervalSince(lastCheck) >= 30.0
        } else {
            shouldCheckPrayerChange = true
        }

        if shouldCheckPrayerChange, let location = lastCalculatedLocation {
            lastPrayerCheckTime = now

            // Only recalculate if we're near a prayer time transition (within 2 minutes)
            let isNearTransition = prayerTimes.contains { prayer in
                let timeUntil = prayer.time.timeIntervalSince(now)
                return abs(timeUntil) < 120 // Within 2 minutes
            }

            if isNearTransition {
                calculatePrayerTimes(for: location)
            }
        }
    }
}

// MARK: - Computed Properties for UI

extension PrayerTimesViewModel {
    /// Whether we have valid prayer times to display
    var hasPrayerTimes: Bool {
        !prayerTimes.isEmpty
    }

    /// Status message for UI
    var statusMessage: String {
        if isLoading {
            return "Calculating prayer times..."
        }

        if let error = errorMessage {
            return error
        }

        if prayerTimes.isEmpty {
            return "Location required to calculate prayer times"
        }

        return ""
    }

    /// Next prayer name (for quick display)
    var nextPrayerName: String {
        nextPrayer?.name ?? "--"
    }

    /// Next prayer time formatted
    var nextPrayerTime: String {
        nextPrayer?.formattedTime ?? "--"
    }

    /// Next prayer countdown
    var nextPrayerCountdown: String {
        nextPrayer?.countdown ?? "--"
    }
}
