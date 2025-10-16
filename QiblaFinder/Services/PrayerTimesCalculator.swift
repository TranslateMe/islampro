import Foundation
import CoreLocation
import Adhan

// MARK: - PrayerTimesCalculator

/// Static calculator for determining Islamic prayer times using Adhan library
/// Provides clean Swift API wrapper around Adhan calculations
///
/// Design Philosophy:
/// - Pure calculation logic - no state, no side effects
/// - Smart defaults - Muslim World League method (widely accepted)
/// - Madhab support - Hanafi vs Shafi Asr calculation
/// - Edge case handling - High latitudes, polar regions
/// - Clean API - Returns formatted, ready-to-display times
///
/// Prayer Times:
/// 1. Fajr (Dawn) - Before sunrise
/// 2. Sunrise - Solar event (not a prayer)
/// 3. Dhuhr (Noon) - After sun passes zenith
/// 4. Asr (Afternoon) - Shadow length based (madhab dependent)
/// 5. Maghrib (Sunset) - Right after sunset
/// 6. Isha (Night) - After twilight ends
struct PrayerTimesCalculator {

    // MARK: - Public Methods

    /// Calculate prayer times for a given location and date
    /// - Parameters:
    ///   - location: User's location (latitude/longitude)
    ///   - date: Date to calculate for (defaults to today)
    ///   - method: Calculation method (defaults to Muslim World League)
    ///   - madhab: Asr calculation method (defaults to Shafi)
    /// - Returns: CalculatedPrayerTimes with all 6 times (5 prayers + sunrise)
    ///
    /// Calculation Methods:
    /// - Muslim World League: Used worldwide (default)
    /// - North America (ISNA): Used in US/Canada
    /// - Egyptian: Used in Egypt, Middle East
    /// - Umm al-Qura: Used in Saudi Arabia
    /// - Dubai: Used in UAE
    /// - And more...
    ///
    /// Test Cases:
    /// - New York: Fajr ~5:30 AM, Dhuhr ~12:00 PM, Asr ~3:30 PM (summer)
    /// - London: Fajr ~3:00 AM, Dhuhr ~1:00 PM, Asr ~5:30 PM (summer)
    /// - Mecca: Fajr ~4:30 AM, Dhuhr ~12:30 PM, Asr ~4:00 PM
    static func calculatePrayerTimes(
        for location: CLLocation,
        date: Date = Date(),
        method: PrayerCalculationMethod = .muslimWorldLeague,
        madhab: PrayerMadhab = .shafi
    ) -> CalculatedPrayerTimes? {
        // Convert CLLocation to Adhan Coordinates
        let coordinates = Coordinates(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        // Get calculation parameters for the chosen method
        var params = method.adhanParameters

        // Set madhab (affects Asr calculation)
        // Hanafi: Asr when shadow = 2x object length
        // Shafi/Maliki/Hanbali: Asr when shadow = 1x object length (earlier)
        params.madhab = madhab.adhanMadhab

        // Apply high latitude rule if needed (above 48° latitude)
        // This handles extreme latitudes where twilight may not end
        if abs(location.coordinate.latitude) > 48 {
            params.highLatitudeRule = .middleOfTheNight
        }

        // Convert date to DateComponents for Adhan library
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        // Calculate prayer times using Adhan library
        guard let prayerTimes = Adhan.PrayerTimes(
            coordinates: coordinates,
            date: dateComponents,
            calculationParameters: params
        ) else {
            // Edge case: Failed to calculate (polar night/day, invalid location)
            return nil
        }

        // Return formatted prayer times
        return CalculatedPrayerTimes(
            fajr: prayerTimes.fajr,
            sunrise: prayerTimes.sunrise,
            dhuhr: prayerTimes.dhuhr,
            asr: prayerTimes.asr,
            maghrib: prayerTimes.maghrib,
            isha: prayerTimes.isha,
            date: date,
            location: location,
            method: method,
            madhab: madhab
        )
    }

    /// Get the next upcoming prayer time from current time
    /// - Parameter times: Calculated prayer times for today
    /// - Returns: The next prayer (or nil if all prayers have passed)
    ///
    /// Logic:
    /// - Compare current time with each prayer time in order
    /// - Return first prayer that is still upcoming
    /// - If all passed, return nil (caller should calculate for tomorrow)
    static func nextPrayer(from times: CalculatedPrayerTimes) -> Prayer? {
        let now = Date()

        // Check each prayer in chronological order
        if now < times.fajr { return .fajr }
        if now < times.sunrise { return .sunrise }
        if now < times.dhuhr { return .dhuhr }
        if now < times.asr { return .asr }
        if now < times.maghrib { return .maghrib }
        if now < times.isha { return .isha }

        // All prayers have passed for today
        return nil
    }

    /// Get the current prayer time (the one we're currently in)
    /// - Parameter times: Calculated prayer times for today
    /// - Returns: The current prayer period (or nil if before Fajr)
    ///
    /// Example:
    /// - 2:00 AM → nil (before Fajr)
    /// - 6:00 AM → Fajr period (between Fajr and Sunrise)
    /// - 1:00 PM → Dhuhr period (between Dhuhr and Asr)
    static func currentPrayer(from times: CalculatedPrayerTimes) -> Prayer? {
        let now = Date()

        // Before Fajr - no current prayer
        if now < times.fajr { return nil }

        // Between Fajr and Sunrise
        if now < times.sunrise { return .fajr }

        // Between Sunrise and Dhuhr (no prayer period)
        if now < times.dhuhr { return .sunrise }

        // Between Dhuhr and Asr
        if now < times.asr { return .dhuhr }

        // Between Asr and Maghrib
        if now < times.maghrib { return .asr }

        // Between Maghrib and Isha
        if now < times.isha { return .maghrib }

        // After Isha (last prayer of the day)
        return .isha
    }
}

// MARK: - Prayer Calculation Method

/// Islamic prayer time calculation methods
/// Different organizations use different angles for Fajr/Isha
enum PrayerCalculationMethod: String, CaseIterable, Identifiable {
    case muslimWorldLeague = "Muslim World League"
    case northAmerica = "ISNA (North America)"
    case egyptian = "Egyptian General Authority"
    case ummAlQura = "Umm al-Qura (Saudi Arabia)"
    case dubai = "Dubai"
    case moonsightingCommittee = "Moonsighting Committee"
    case kuwait = "Kuwait"
    case qatar = "Qatar"
    case singapore = "Singapore"
    case tehran = "Tehran"
    case turkey = "Turkey"

    var id: String { rawValue }

    /// Convert to Adhan library CalculationParameters
    var adhanParameters: CalculationParameters {
        switch self {
        case .muslimWorldLeague:
            return CalculationMethod.muslimWorldLeague.params
        case .northAmerica:
            return CalculationMethod.northAmerica.params
        case .egyptian:
            return CalculationMethod.egyptian.params
        case .ummAlQura:
            return CalculationMethod.ummAlQura.params
        case .dubai:
            return CalculationMethod.dubai.params
        case .moonsightingCommittee:
            return CalculationMethod.moonsightingCommittee.params
        case .kuwait:
            return CalculationMethod.kuwait.params
        case .qatar:
            return CalculationMethod.qatar.params
        case .singapore:
            return CalculationMethod.singapore.params
        case .tehran:
            return CalculationMethod.tehran.params
        case .turkey:
            return CalculationMethod.turkey.params
        }
    }

    /// Short description of method
    var description: String {
        switch self {
        case .muslimWorldLeague:
            return "Widely used worldwide"
        case .northAmerica:
            return "Used in US/Canada"
        case .egyptian:
            return "Used in Egypt, Middle East"
        case .ummAlQura:
            return "Official method in Saudi Arabia"
        case .dubai:
            return "Used in UAE"
        case .moonsightingCommittee:
            return "Used by some communities in US"
        case .kuwait:
            return "Used in Kuwait"
        case .qatar:
            return "Used in Qatar"
        case .singapore:
            return "Used in Singapore, Malaysia"
        case .tehran:
            return "Used in Iran"
        case .turkey:
            return "Used in Turkey"
        }
    }
}

// MARK: - Prayer Madhab

/// Islamic jurisprudence schools for Asr calculation
/// Affects when Asr prayer time begins
enum PrayerMadhab: String, CaseIterable, Identifiable {
    case shafi = "Shafi/Maliki/Hanbali"
    case hanafi = "Hanafi"

    var id: String { rawValue }

    /// Convert to Adhan library Madhab
    var adhanMadhab: Madhab {
        switch self {
        case .shafi:
            return .shafi  // Asr when shadow = 1x object length (earlier)
        case .hanafi:
            return .hanafi  // Asr when shadow = 2x object length (later)
        }
    }

    /// Description of difference
    var description: String {
        switch self {
        case .shafi:
            return "Asr begins earlier (shadow = object length)"
        case .hanafi:
            return "Asr begins later (shadow = 2x object length)"
        }
    }
}

// MARK: - Prayer Enum

/// The five daily prayers + sunrise
enum Prayer: String, CaseIterable, Identifiable {
    case fajr = "Fajr"
    case sunrise = "Sunrise"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"

    var id: String { rawValue }

    /// Arabic name of prayer
    var arabicName: String {
        switch self {
        case .fajr: return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }

    /// English description
    var description: String {
        switch self {
        case .fajr: return "Dawn"
        case .sunrise: return "Sunrise"
        case .dhuhr: return "Noon"
        case .asr: return "Afternoon"
        case .maghrib: return "Sunset"
        case .isha: return "Night"
        }
    }

    /// Whether this is an actual prayer (false for sunrise)
    var isPrayer: Bool {
        return self != .sunrise
    }
}

// MARK: - CalculatedPrayerTimes Model

/// Calculated prayer times for a specific date and location
struct CalculatedPrayerTimes {
    // Prayer times
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date

    // Calculation metadata
    let date: Date
    let location: CLLocation
    let method: PrayerCalculationMethod
    let madhab: PrayerMadhab

    /// Get time for a specific prayer
    func time(for prayer: Prayer) -> Date {
        switch prayer {
        case .fajr: return fajr
        case .sunrise: return sunrise
        case .dhuhr: return dhuhr
        case .asr: return asr
        case .maghrib: return maghrib
        case .isha: return isha
        }
    }

    /// Get formatted time string (e.g., "5:30 AM")
    func formattedTime(for prayer: Prayer) -> String {
        let time = time(for: prayer)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: time)
    }

    /// Get time remaining until prayer (e.g., "2h 15m")
    func timeRemaining(until prayer: Prayer) -> String {
        let time = time(for: prayer)
        let now = Date()
        let interval = time.timeIntervalSince(now)

        // If time has passed
        if interval < 0 {
            return "Passed"
        }

        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
