import Foundation
import SwiftUI
import CoreLocation

// MARK: - Double Extensions
extension Double {
    /// Converts bearing to cardinal direction (N, NE, E, SE, S, SW, W, NW)
    var cardinalDirection: String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((self + 22.5) / 45.0) % 8
        return directions[index]
    }

    /// Formats bearing as "285° NW"
    var formattedBearing: String {
        return "\(Int(self))° \(cardinalDirection)"
    }

    /// Formats distance in km with thousand separators
    func formattedDistance() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))"
    }

    /// Converts radians to degrees
    var toDegrees: Double {
        return self * 180.0 / .pi
    }

    /// Converts degrees to radians
    var toRadians: Double {
        return self * .pi / 180.0
    }
}

// MARK: - Date Extensions
extension Date {
    /// Returns countdown string like "in 2h 15m" or "Now"
    func countdownString(from referenceDate: Date = Date()) -> String {
        let interval = self.timeIntervalSince(referenceDate)

        if interval < 0 {
            return NSLocalizedString("Passed", comment: "Prayer time has passed")
        }

        if interval < 60 {
            return NSLocalizedString("Now", comment: "Prayer time is now")
        }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return String(format: NSLocalizedString("in %dh %dm", comment: "Countdown format"), hours, minutes)
        } else {
            return String(format: NSLocalizedString("in %dm", comment: "Countdown format minutes"), minutes)
        }
    }

    /// Formats time as "5:42 AM"
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Returns Hijri date string using Foundation Calendar
    func hijriDateString(locale: Locale = .current) -> String {
        let hijriCalendar = Calendar(identifier: .islamicCivil)
        let components = hijriCalendar.dateComponents([.day, .month, .year], from: self)

        guard let day = components.day,
              let month = components.month,
              let year = components.year else {
            return ""
        }

        let monthNames = [
            "Muharram", "Safar", "Rabi' al-awwal", "Rabi' al-thani",
            "Jumada al-awwal", "Jumada al-thani", "Rajab", "Sha'ban",
            "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"
        ]

        let monthName = monthNames[month - 1]
        return "\(day) \(monthName) \(year)"
    }
}

// MARK: - Color Extensions
extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Gold color for Kaaba icon (default theme color)
    static let gold = Color(hex: Constants.GOLD_COLOR)
}

// MARK: - Theme Environment Keys
private struct ThemeColorKey: EnvironmentKey {
    static let defaultValue: Color = Color(hex: Constants.GOLD_COLOR)
}

private struct ThemeBackgroundKey: EnvironmentKey {
    static let defaultValue: Color = Color.black
}

private struct ThemeSecondaryBackgroundKey: EnvironmentKey {
    static let defaultValue: Color = Color(hex: "1A1A1A")
}

private struct ThemeTextPrimaryKey: EnvironmentKey {
    static let defaultValue: Color = Color.white
}

private struct ThemeTextSecondaryKey: EnvironmentKey {
    static let defaultValue: Color = Color.white.opacity(0.7)
}

extension EnvironmentValues {
    var themeColor: Color {
        get { self[ThemeColorKey.self] }
        set { self[ThemeColorKey.self] = newValue }
    }

    var themeBackground: Color {
        get { self[ThemeBackgroundKey.self] }
        set { self[ThemeBackgroundKey.self] = newValue }
    }

    var themeSecondaryBackground: Color {
        get { self[ThemeSecondaryBackgroundKey.self] }
        set { self[ThemeSecondaryBackgroundKey.self] = newValue }
    }

    var themeTextPrimary: Color {
        get { self[ThemeTextPrimaryKey.self] }
        set { self[ThemeTextPrimaryKey.self] = newValue }
    }

    var themeTextSecondary: Color {
        get { self[ThemeTextSecondaryKey.self] }
        set { self[ThemeTextSecondaryKey.self] = newValue }
    }
}

extension View {
    func themeColor(_ color: Color) -> some View {
        environment(\.themeColor, color)
    }

    func themeBackground(_ color: Color) -> some View {
        environment(\.themeBackground, color)
    }

    func themeSecondaryBackground(_ color: Color) -> some View {
        environment(\.themeSecondaryBackground, color)
    }

    /// Apply all theme colors at once
    func applyTheme(_ theme: AppTheme) -> some View {
        self
            .environment(\.themeColor, theme.primaryColor)
            .environment(\.themeBackground, theme.backgroundColor)
            .environment(\.themeSecondaryBackground, theme.secondaryBackgroundColor)
            .environment(\.themeTextPrimary, theme.textPrimary)
            .environment(\.themeTextSecondary, theme.textSecondary)
    }
}

// MARK: - String Extensions
extension String {
    /// Localized string helper
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// Localized string with arguments
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - CLLocation Extensions
extension CLLocation {
    /// Calculate distance to Mecca
    var distanceToMecca: Double {
        let meccaLocation = CLLocation(
            latitude: Constants.MECCA_LATITUDE,
            longitude: Constants.MECCA_LONGITUDE
        )
        return distance(from: meccaLocation)
    }

    /// Calculate distance to Mecca in kilometers
    var distanceToMeccaKm: Double {
        return distanceToMecca / 1000.0
    }
}

// MARK: - NotificationCenter Extensions
extension Notification.Name {
    /// Posted when notification settings change (enable/disable, timing)
    static let notificationSettingsChanged = Notification.Name("notificationSettingsChanged")

    /// Posted when app theme changes
    static let themeChanged = Notification.Name("themeChanged")

    /// Posted when prayer calculation method changes
    static let calculationMethodChanged = Notification.Name("calculationMethodChanged")

    /// Posted when madhab (Asr calculation) changes
    static let madhabChanged = Notification.Name("madhabChanged")
}
