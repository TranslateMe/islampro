import Foundation
import UserNotifications
import Combine
import UIKit

/// Manages prayer time notifications
/// Schedules notifications for upcoming prayers based on user preferences
class NotificationManager: ObservableObject {

    static let shared = NotificationManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    /// Request notification permission from user
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.checkAuthorizationStatus()
                } else if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Check current notification authorization status
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }

    // MARK: - Schedule Notifications

    /// Schedule notifications for all prayer times
    /// - Parameters:
    ///   - prayerTimes: Array of prayer times to schedule notifications for
    ///   - minutesBefore: How many minutes before prayer to notify (0 = at prayer time)
    func schedulePrayerNotifications(prayerTimes: [PrayerTimeDisplay], minutesBefore: Int) {
        // Remove all existing notifications first
        cancelAllNotifications()

        // Check if notifications are enabled in settings
        guard UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.notificationsEnabled) else {
            return
        }

        // Check authorization status
        guard authorizationStatus == .authorized else {
            return
        }

        // Schedule notification for each prayer
        for prayer in prayerTimes {
            // Skip sunrise (not a prayer time)
            guard prayer.name != "Sunrise" else { continue }

            // Calculate notification time (prayer time minus minutes before)
            let notificationDate = prayer.time.addingTimeInterval(-Double(minutesBefore * 60))

            // Only schedule if notification time is in the future
            guard notificationDate > Date() else { continue }

            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("prayer_time_notification_title", comment: "Prayer time notification")
            content.body = String(format: NSLocalizedString("prayer_time_notification_body", comment: "Prayer notification body"), prayer.name)
            content.sound = .default
            content.badge = 1

            // Create trigger for specific date
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            // Create request with unique identifier
            let identifier = "prayer-\(prayer.name)-\(notificationDate.timeIntervalSince1970)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            // Add to notification center
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification for \(prayer.name): \(error.localizedDescription)")
                }
            }
        }
    }

    /// Cancel all scheduled notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Cancel all delivered notifications (badge count)
    func clearDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        // Clear badge count using modern iOS 17+ API
        Task {
            try? await UNUserNotificationCenter.current().setBadgeCount(0)
        }
    }
}
