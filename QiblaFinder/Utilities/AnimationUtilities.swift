import SwiftUI

/// Centralized animation utilities and constants for consistent app-wide animations
/// All animations designed for 60fps performance and natural feel
///
/// Design Philosophy:
/// - Spring animations for organic feel
/// - Subtle, not distracting
/// - Consistent timing across app
/// - Performance-first (GPU-accelerated)
/// - Enhances usability
struct AnimationUtilities {

    // MARK: - Animation Constants

    /// Standard animation durations
    struct Duration {
        /// Quick feedback animations (button press, toggles)
        static let quick: Double = 0.15

        /// Standard UI transitions (view changes, fades)
        static let standard: Double = 0.3

        /// Smooth entrance animations
        static let entrance: Double = 0.5

        /// Long-form animations (page transitions)
        static let long: Double = 0.7
    }

    /// Spring animation parameters for natural feel
    struct Spring {
        /// Bouncy spring (buttons, interactive elements)
        static let bouncy = Animation.spring(response: 0.3, dampingFraction: 0.6)

        /// Smooth spring (view transitions)
        static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)

        /// Gentle spring (subtle movements)
        static let gentle = Animation.spring(response: 0.5, dampingFraction: 1.0)

        /// Snappy spring (quick feedback)
        static let snappy = Animation.spring(response: 0.2, dampingFraction: 0.7)
    }

    /// Easing curves for non-spring animations
    struct Easing {
        static let easeInOut = Animation.easeInOut(duration: Duration.standard)
        static let easeOut = Animation.easeOut(duration: Duration.standard)
        static let easeIn = Animation.easeIn(duration: Duration.standard)
        static let linear = Animation.linear(duration: Duration.standard)
    }

    /// Delays for staggered animations
    struct Delay {
        /// Delay between staggered items (e.g., prayer rows)
        static let stagger: Double = 0.08

        /// Delay before entrance animation starts
        static let entrance: Double = 0.1

        /// Delay for sequential UI updates
        static let sequential: Double = 0.15
    }

    // MARK: - Animation Presets

    /// Fade + scale entrance animation
    static var entranceFadeScale: Animation {
        Spring.smooth
    }

    /// Quick button press animation
    static var buttonPress: Animation {
        Spring.bouncy
    }

    /// Smooth tab transition
    static var tabTransition: Animation {
        Spring.gentle
    }

    /// Loading state animation
    static var loading: Animation {
        Easing.easeInOut
    }

    /// Error shake animation
    static var errorShake: Animation {
        Spring.snappy
    }

    // MARK: - Transition Helpers

    /// Standard fade transition
    static var fadeTransition: AnyTransition {
        .opacity
    }

    /// Scale + fade transition
    static var scaleFadeTransition: AnyTransition {
        .scale(scale: 0.95).combined(with: .opacity)
    }

    /// Slide from bottom transition
    static var slideUpTransition: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }

    /// Slide from top transition
    static var slideDownTransition: AnyTransition {
        .move(edge: .top).combined(with: .opacity)
    }
}

// MARK: - View Extension for Entrance Animations

extension View {
    /// Adds a fade + scale entrance animation to a view
    /// - Parameters:
    ///   - delay: Delay before animation starts (default: 0)
    ///   - duration: Animation duration (default: 0.5)
    /// - Returns: View with entrance animation
    func entranceAnimation(delay: Double = 0) -> some View {
        self.modifier(EntranceAnimationModifier(delay: delay))
    }

    /// Adds a staggered entrance animation (for list items)
    /// - Parameter index: Index of item for stagger calculation
    /// - Returns: View with staggered entrance animation
    func staggeredEntrance(index: Int) -> some View {
        self.modifier(StaggeredEntranceModifier(index: index))
    }

    /// Adds a button press scale animation
    /// - Parameter isPressed: Whether button is currently pressed
    /// - Returns: View with press animation
    func buttonPressAnimation(isPressed: Bool) -> some View {
        self.modifier(ButtonPressModifier(isPressed: isPressed))
    }

    /// Adds a shake animation (for errors)
    /// - Parameter trigger: Value that triggers shake when changed
    /// - Returns: View with shake animation
    func shake(trigger: Int) -> some View {
        self.modifier(ShakeModifier(trigger: trigger))
    }

    /// Adds a pulse animation (for attention)
    /// - Parameter isActive: Whether pulse is active
    /// - Returns: View with pulse animation
    func pulse(isActive: Bool) -> some View {
        self.modifier(PulseModifier(isActive: isActive))
    }
}

// MARK: - Animation Modifiers

/// Entrance animation modifier (fade + scale)
private struct EntranceAnimationModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : 0.95)
            .opacity(isVisible ? 1.0 : 0.0)
            .onAppear {
                withAnimation(AnimationUtilities.entranceFadeScale.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

/// Staggered entrance animation modifier
private struct StaggeredEntranceModifier: ViewModifier {
    let index: Int
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .offset(y: isVisible ? 0 : 10)
            .onAppear {
                let staggerDelay = AnimationUtilities.Delay.stagger * Double(index)
                withAnimation(
                    AnimationUtilities.Spring.gentle.delay(staggerDelay)
                ) {
                    isVisible = true
                }
            }
    }
}

/// Button press animation modifier
private struct ButtonPressModifier: ViewModifier {
    let isPressed: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(AnimationUtilities.buttonPress, value: isPressed)
    }
}

/// Shake animation modifier
private struct ShakeModifier: ViewModifier {
    let trigger: Int
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _, _ in
                // Shake sequence: right, left, right, center
                withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
                    offset = 10
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
                        offset = -10
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
                        offset = 5
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        offset = 0
                    }
                }
            }
    }
}

/// Pulse animation modifier
private struct PulseModifier: ViewModifier {
    let isActive: Bool
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startPulse()
                } else {
                    stopPulse()
                }
            }
            .onAppear {
                if isActive {
                    startPulse()
                }
            }
    }

    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true)
        ) {
            scale = 1.05
        }
    }

    private func stopPulse() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 1.0
        }
    }
}

// MARK: - Skeleton Loading View

/// Skeleton loading placeholder view with shimmer animation
struct SkeletonView: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    @State private var shimmerOffset: CGFloat = -200

    init(
        width: CGFloat? = nil,
        height: CGFloat = 20,
        cornerRadius: CGFloat = 8
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .overlay(
                // Shimmer effect
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmerOffset)
                    .onAppear {
                        withAnimation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            shimmerOffset = 400
                        }
                    }
            )
            .clipped()
    }
}

// MARK: - Haptic Feedback Utilities

/// Centralized haptic feedback manager
struct HapticFeedback {

    /// Light impact (button taps, toggles)
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact (navigation, selections)
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact (confirmations, important actions)
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Success notification (completed actions)
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification (caution states)
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification (failed actions)
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    /// Selection changed (picker, tabs)
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Button Styles

/// Button style with scale animation on press
struct ScaleButtonStyle: ButtonStyle {
    let scale: CGFloat

    init(scale: CGFloat = 0.96) {
        self.scale = scale
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(AnimationUtilities.buttonPress, value: configuration.isPressed)
    }
}
