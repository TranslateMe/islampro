import UIKit

/// Manages haptic feedback for the app
/// Provides multimodal feedback (visual + audio + haptic) for critical events
///
/// Design Philosophy:
/// - MEDIUM intensity - noticeable but not jarring for prayer context
/// - Battery optimized - prepare on demand, release when done
/// - Immediate feedback - no delay, triggers instantly
/// - Single fire - once per event, no repeated vibrations
///
/// Primary Use Case:
/// - Qibla alignment confirmation (visual glow + VoiceOver + haptic)
/// - Triggers when isAligned changes false → true ONLY
/// - Does NOT trigger when alignment is lost (respectful, not annoying)
///
/// Battery Optimization:
/// - Generator prepared when compass view appears
/// - Generator released when compass view disappears
/// - Minimal battery impact with proper lifecycle management
class HapticManager {

    // MARK: - Singleton

    static let shared = HapticManager()

    private init() {}

    // MARK: - Private Properties

    /// Impact feedback generator (.medium intensity)
    /// Medium = noticeable confirmation without being jarring
    /// Perfect for prayer app context (professional, respectful)
    private var impactGenerator: UIImpactFeedbackGenerator?

    // MARK: - Public Methods

    /// Prepares haptic engine for immediate response
    /// Call this when view appears or before first use
    /// Battery-optimized: only prepares when needed
    func prepare() {
        impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator?.prepare()
    }

    /// Releases haptic engine to save battery
    /// Call this when view disappears or haptic no longer needed
    func release() {
        impactGenerator = nil
    }

    /// Triggers alignment haptic feedback
    /// Medium impact - noticeable but not jarring
    /// Use for Qibla alignment confirmation only
    ///
    /// Usage:
    /// ```swift
    /// if !previousAlignment && isAligned {
    ///     HapticManager.shared.triggerAlignment()
    /// }
    /// ```
    func triggerAlignment() {
        // Ensure generator is prepared
        // If not prepared, create on-demand (fallback)
        if impactGenerator == nil {
            impactGenerator = UIImpactFeedbackGenerator(style: .medium)
            impactGenerator?.prepare()
        }

        // Trigger immediate haptic feedback
        impactGenerator?.impactOccurred()

        // Re-prepare for next use (iOS best practice)
        impactGenerator?.prepare()
    }

    /// Triggers general success haptic
    /// Use for other success events in the app (prayer time notifications, etc.)
    func triggerSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Triggers error haptic
    /// Use for errors that need user attention
    func triggerError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    /// Triggers warning haptic
    /// Use for warnings or cautions
    func triggerWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
