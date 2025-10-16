import Foundation
import SwiftUI
import Combine

/// ViewModel for managing app settings and premium status
/// Handles UserDefaults persistence and premium feature access
///
/// Design Philosophy:
/// - UserDefaults for persistent settings
/// - @Published properties for reactive UI
/// - Premium feature gating via StoreManager
/// - Clean default values
@MainActor
class SettingsViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Calculation method for prayer times
    @Published var calculationMethod: PrayerCalculationMethod {
        didSet {
            UserDefaults.standard.set(calculationMethod.rawValue, forKey: Constants.UserDefaultsKeys.selectedCalculationMethod)
            // Trigger prayer time recalculation
            NotificationCenter.default.post(name: .calculationMethodChanged, object: nil)
        }
    }

    /// Madhab for Asr calculation
    @Published var madhab: PrayerMadhab {
        didSet {
            UserDefaults.standard.set(madhab.rawValue, forKey: "selectedMadhab")
            // Trigger prayer time recalculation
            NotificationCenter.default.post(name: .madhabChanged, object: nil)
        }
    }

    /// Whether notifications are enabled (Premium)
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Constants.UserDefaultsKeys.notificationsEnabled)
            // Trigger notification rescheduling when settings change
            NotificationCenter.default.post(name: .notificationSettingsChanged, object: nil)
        }
    }

    /// Minutes before prayer to notify (Premium)
    @Published var notificationMinutesBefore: Int {
        didSet {
            UserDefaults.standard.set(notificationMinutesBefore, forKey: Constants.UserDefaultsKeys.notificationMinutesBefore)
            // Trigger notification rescheduling when settings change
            NotificationCenter.default.post(name: .notificationSettingsChanged, object: nil)
        }
    }

    /// Selected theme (Premium)
    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: Constants.UserDefaultsKeys.selectedTheme)
            // Trigger theme update across app
            NotificationCenter.default.post(name: .themeChanged, object: nil)
        }
    }

    // MARK: - Properties

    /// Reference to store manager (for premium status)
    private let storeManager = StoreManager.shared

    // MARK: - Initialization

    init() {
        // Load calculation method
        if let methodRaw = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.selectedCalculationMethod),
           let method = PrayerCalculationMethod(rawValue: methodRaw) {
            self.calculationMethod = method
        } else {
            self.calculationMethod = .muslimWorldLeague  // Default
        }

        // Load madhab
        if let madhabRaw = UserDefaults.standard.string(forKey: "selectedMadhab"),
           let madhab = PrayerMadhab(rawValue: madhabRaw) {
            self.madhab = madhab
        } else {
            self.madhab = .shafi  // Default
        }

        // Load notifications
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.notificationsEnabled)

        // Load notification minutes (default to 15 if not set)
        let savedMinutes = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.notificationMinutesBefore)
        self.notificationMinutesBefore = savedMinutes > 0 ? savedMinutes : 15

        // Load theme
        if let themeRaw = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.selectedTheme),
           let theme = AppTheme(rawValue: themeRaw) {
            self.selectedTheme = theme
        } else {
            self.selectedTheme = .classic  // Default
        }
    }

    // MARK: - Premium Features
    // NOTE: All features unlocked for free access
    // Premium infrastructure kept for future monetization options

    /// Whether user has premium (UNLOCKED - all features free)
    var isPremium: Bool {
        // return storeManager.isPremium  // Commented out - all features unlocked
        return true  // Always return true - all features available
    }

    /// Whether notifications feature is available (UNLOCKED)
    var notificationsAvailable: Bool {
        return true  // Always available
    }

    /// Whether theme customization is available (UNLOCKED)
    var themesAvailable: Bool {
        return true  // Always available
    }

    /// Premium price string (delegates to StoreManager)
    var premiumPrice: String {
        return storeManager.premiumPrice
    }

    /// Whether a purchase is in progress
    var isPurchasing: Bool {
        return storeManager.isLoading
    }

    /// Purchase error message (if any)
    var purchaseError: String? {
        return storeManager.purchaseError
    }

    // MARK: - Premium Actions

    /// Purchase premium via StoreKit
    func purchasePremium() {
        Task {
            await storeManager.purchasePremium()
        }
    }

    /// Restore previous purchases
    func restorePurchases() {
        Task {
            await storeManager.restorePurchases()
        }
    }
}

// MARK: - AppTheme Enum

/// Available app themes (Premium feature)
enum AppTheme: String, CaseIterable, Identifiable {
    case classic = "Classic (Black & Gold)"
    case midnight = "Midnight Blue"
    case forest = "Forest Green"
    case desert = "Desert Sand"

    var id: String { rawValue }

    /// Primary accent color for theme
    var primaryColor: Color {
        switch self {
        case .classic:
            return Color(hex: Constants.GOLD_COLOR)
        case .midnight:
            return Color(hex: "4A90E2")  // Bright blue
        case .forest:
            return Color(hex: "27AE60")  // Vibrant green
        case .desert:
            return Color(hex: "F39C12")  // Warm orange
        }
    }

    /// Primary background color for theme
    var backgroundColor: Color {
        switch self {
        case .classic:
            return Color.black
        case .midnight:
            return Color(hex: "1A1A2E")  // Deep navy
        case .forest:
            return Color(hex: "1C2A1A")  // Deep forest
        case .desert:
            return Color(hex: "2A1A10")  // Deep brown
        }
    }

    /// Secondary background color for theme (cards, sections)
    var secondaryBackgroundColor: Color {
        switch self {
        case .classic:
            return Color(hex: "1A1A1A")  // Dark gray
        case .midnight:
            return Color(hex: "2E2E3E")  // Lighter navy
        case .forest:
            return Color(hex: "2A3A28")  // Lighter forest
        case .desert:
            return Color(hex: "3A2A20")  // Lighter brown
        }
    }

    /// Primary text color for theme (adapts to background brightness)
    var textPrimary: Color {
        switch self {
        case .classic:
            return Color.white  // White on black
        case .midnight, .forest, .desert:
            return Color.white  // White on all dark backgrounds
        }
    }

    /// Secondary text color for theme (muted)
    var textSecondary: Color {
        switch self {
        case .classic:
            return Color.white.opacity(0.7)
        case .midnight, .forest, .desert:
            return Color.white.opacity(0.6)
        }
    }
}
