import Foundation
import CoreGraphics

struct Constants {
    // MARK: - Mecca Coordinates
    static let MECCA_LATITUDE: Double = 21.4225
    static let MECCA_LONGITUDE: Double = 39.8262

    // MARK: - Qibla Settings
    static let QIBLA_ALIGNMENT_THRESHOLD: Double = 5.0 // degrees
    static let LOCATION_CACHE_DURATION: TimeInterval = 24 * 60 * 60 // 24 hours
    static let SIGNIFICANT_LOCATION_CHANGE: Double = 50_000 // 50km in meters

    // MARK: - Compass Settings
    static let COMPASS_UPDATE_FREQUENCY: Double = 60.0 // Hz
    static let COMPASS_ANIMATION_DURATION: Double = 0.2 // seconds

    // MARK: - UI Constants
    static let COMPASS_RING_DIAMETER: CGFloat = 300
    static let COMPASS_RING_STROKE_WIDTH: CGFloat = 2
    static let KAABA_ICON_SIZE: CGFloat = 50
    static let ACCURACY_INDICATOR_SIZE: CGFloat = 12

    // MARK: - Colors
    static let GOLD_COLOR: String = "#FFD700"
    static let PRIMARY_GREEN: String = "#34C759"

    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let cachedLatitude = "cached_location_latitude"
        static let cachedLongitude = "cached_location_longitude"
        static let cachedTimestamp = "cached_location_timestamp"
        static let hasSeenOnboarding = "has_seen_onboarding"
        static let isPremium = "is_premium_unlocked"
        static let selectedCalculationMethod = "selected_calculation_method"
        static let selectedTheme = "selected_theme"
        static let notificationsEnabled = "notifications_enabled"
        static let notificationMinutesBefore = "notification_minutes_before"
    }

    // MARK: - App Groups (for Widget)
    static let APP_GROUP_ID = "group.com.qiblafinder.app"

    // MARK: - StoreKit
    static let PREMIUM_PRODUCT_ID = "com.qiblafinder.premium"
}
