import Foundation

// MARK: - PrayerTimeDisplay

/// Display model for a single prayer time row in the UI
/// Clean data container that combines Prayer enum with time and state
///
/// Design Philosophy:
/// - Simple struct - just data, no logic
/// - Computed properties for formatting (uses Extensions)
/// - Identifiable for SwiftUI Lists
/// - Ready for immediate display
///
/// Usage:
/// ```swift
/// PrayerTimeDisplay(
///     prayer: .fajr,
///     time: Date(),
///     isNext: true,
///     isCurrent: false
/// )
/// ```
struct PrayerTimeDisplay: Identifiable {

    // MARK: - Properties

    /// Prayer type (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
    let prayer: Prayer

    /// Time this prayer occurs
    let time: Date

    /// Whether this is the next upcoming prayer
    /// Used for visual highlighting in UI
    let isNext: Bool

    /// Whether prayer time is happening now
    /// Used for "current prayer" indicator
    let isCurrent: Bool

    /// Unique identifier for SwiftUI List
    var id: String { prayer.id }

    // MARK: - Display Properties

    /// English name (e.g., "Fajr", "Dhuhr")
    var name: String {
        prayer.rawValue
    }

    /// Arabic name (e.g., "الفجر", "الظهر")
    var arabicName: String {
        prayer.arabicName
    }

    /// English description (e.g., "Dawn", "Noon")
    var description: String {
        prayer.description
    }

    /// Whether this is an actual prayer (false for sunrise)
    var isPrayer: Bool {
        prayer.isPrayer
    }

    // MARK: - Computed Properties (Using Extensions)

    /// Formatted time string (e.g., "5:42 AM")
    /// Uses Date extension from Extensions.swift
    var formattedTime: String {
        time.formattedTime()
    }

    /// Countdown string from now (e.g., "in 2h 15m", "Now", "Passed")
    /// Uses Date extension from Extensions.swift
    var countdown: String {
        time.countdownString(from: Date())
    }

    /// Time remaining in minutes (for sorting/logic)
    /// Positive = upcoming, Negative = passed
    var minutesRemaining: Int {
        let interval = time.timeIntervalSince(Date())
        return Int(interval / 60)
    }

    /// Whether this prayer time has passed
    var hasPassed: Bool {
        time < Date()
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension PrayerTimeDisplay {
    /// Create sample prayer for previews
    static func sample(
        prayer: Prayer = .fajr,
        hoursFromNow: Double = 0,
        isNext: Bool = false,
        isCurrent: Bool = false
    ) -> PrayerTimeDisplay {
        let time = Date().addingTimeInterval(hoursFromNow * 3600)
        return PrayerTimeDisplay(
            prayer: prayer,
            time: time,
            isNext: isNext,
            isCurrent: isCurrent
        )
    }

    /// Sample prayer times for today (6 prayers)
    static var sampleDay: [PrayerTimeDisplay] {
        [
            .sample(prayer: .fajr, hoursFromNow: -2, isNext: false, isCurrent: false),
            .sample(prayer: .sunrise, hoursFromNow: -1, isNext: false, isCurrent: false),
            .sample(prayer: .dhuhr, hoursFromNow: 2, isNext: true, isCurrent: false),
            .sample(prayer: .asr, hoursFromNow: 5, isNext: false, isCurrent: false),
            .sample(prayer: .maghrib, hoursFromNow: 8, isNext: false, isCurrent: false),
            .sample(prayer: .isha, hoursFromNow: 10, isNext: false, isCurrent: false)
        ]
    }
}
#endif
