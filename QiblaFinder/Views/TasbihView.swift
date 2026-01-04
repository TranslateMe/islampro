import SwiftUI

/// Tasbih (digital prayer beads) counter view
/// Simple, beautiful tap counter for dhikr (remembrance) with haptic feedback
///
/// Design Philosophy:
/// - Minimalist, distraction-free interface
/// - Large circular tap area for easy use
/// - Clear visual progress indicator
/// - Smooth animations and transitions
/// - Haptic feedback for engagement
/// - Goal-based tracking with celebration
///
/// Features:
/// - Large tap button in center
/// - Count display with progress circle
/// - Goal selection (33, 99, 100)
/// - Reset button
/// - Completion celebration
/// - Lifetime total count
/// - Works with all app themes
struct TasbihView: View {

    // MARK: - State

    @StateObject private var viewModel = TasbihViewModel()
    @State private var isVisible = false

    // MARK: - Environment

    @Environment(\.themeBackground) private var themeBackground
    @Environment(\.themeSecondaryBackground) private var themeSecondaryBackground
    @Environment(\.themeTextPrimary) private var themeTextPrimary
    @Environment(\.themeTextSecondary) private var themeTextSecondary
    @Environment(\.themeColor) private var themeColor

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            themeBackground
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // Header
                headerView
                    .padding(.top, 40)
                    .opacity(isVisible ? 1.0 : 0.0)

                Spacer()

                // Progress Circle & Count Display
                progressCircleView
                    .padding(.vertical, 20)
                    .opacity(isVisible ? 1.0 : 0.0)

                // Tap Button
                tapButtonView
                    .scaleEffect(isVisible ? 1.0 : 0.8)
                    .opacity(isVisible ? 1.0 : 0.0)

                Spacer()

                // Goal Selection & Reset
                controlsView
                    .padding(.bottom, 40)
                    .opacity(isVisible ? 1.0 : 0.0)
            }

            // Completion Overlay
            if viewModel.showCompletion {
                completionOverlay
            }
        }
        .onAppear {
            withAnimation(AnimationUtilities.Spring.gentle) {
                isVisible = true
            }
        }
    }

    // MARK: - Header View

    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 8) {
            Text(NSLocalizedString("tasbih_counter", comment: "Tasbih Counter"))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(themeTextPrimary)

            Text(NSLocalizedString("tap_to_count", comment: "Tap to count"))
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(themeTextSecondary)
        }
    }

    // MARK: - Progress Circle View

    @ViewBuilder
    private var progressCircleView: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(themeColor.opacity(0.2), lineWidth: 8)
                .frame(width: 220, height: 220)

            // Progress circle
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(themeColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(AnimationUtilities.Spring.gentle, value: viewModel.count)

            // Count display
            VStack(spacing: 4) {
                Text("\(viewModel.count)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(themeTextPrimary)
                    .contentTransition(.numericText())
                    .animation(AnimationUtilities.Spring.snappy, value: viewModel.count)

                Text("/ \(viewModel.goal)")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(themeTextSecondary)
            }
        }
    }

    // MARK: - Tap Button View

    @ViewBuilder
    private var tapButtonView: some View {
        Button(action: {
            viewModel.increment()
        }) {
            Circle()
                .fill(themeColor)
                .frame(width: 180, height: 180)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)

                        Text(NSLocalizedString("tap", comment: "TAP"))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                )
                .shadow(color: themeColor.opacity(0.4), radius: 20)
        }
        .buttonStyle(TasbihButtonStyle())
        .accessibilityLabel(NSLocalizedString("tasbih_button_label", comment: "Tap to count tasbih"))
        .accessibilityHint(NSLocalizedString("tasbih_button_hint", comment: "Tap to increment counter"))
    }

    // MARK: - Controls View

    @ViewBuilder
    private var controlsView: some View {
        VStack(spacing: 20) {
            // Goal Picker
            HStack(spacing: 12) {
                Text(NSLocalizedString("goal", comment: "Goal:"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(themeTextSecondary)

                ForEach(viewModel.getAvailableGoals(), id: \.self) { goal in
                    Button(action: {
                        viewModel.setGoal(goal)
                    }) {
                        Text("\(goal)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(viewModel.goal == goal ? .white : themeTextPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.goal == goal ? themeColor : themeSecondaryBackground.opacity(0.5))
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }

            // Reset Button
            Button(action: {
                viewModel.reset()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16))
                    Text(NSLocalizedString("reset", comment: "Reset"))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(themeColor)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(themeColor, lineWidth: 2)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel(NSLocalizedString("reset_counter", comment: "Reset counter"))

            // Lifetime Count
            Text(String(format: NSLocalizedString("total_count", comment: "Total: %d"), viewModel.totalLifetimeCount))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(themeTextSecondary)
                .accessibilityLabel(String(format: NSLocalizedString("lifetime_tasbih_count", comment: "Total lifetime count: %d"), viewModel.totalLifetimeCount))
        }
    }

    // MARK: - Completion Overlay

    @ViewBuilder
    private var completionOverlay: some View {
        ZStack {
            // Semi-transparent background
            themeBackground.opacity(0.3)
                .ignoresSafeArea()

            // Celebration card
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(Color(hex: Constants.PRIMARY_GREEN))

                Text(NSLocalizedString("mashaallah", comment: "MashaAllah!"))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(themeTextPrimary)

                Text(NSLocalizedString("goal_completed", comment: "Goal Completed ✓"))
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(themeTextSecondary)
            }
            .padding(50)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(themeSecondaryBackground)
                    .shadow(color: Color.black.opacity(0.3), radius: 30)
            )
            .transition(.scale.combined(with: .opacity))
        }
        .animation(AnimationUtilities.Spring.bouncy, value: viewModel.showCompletion)
    }
}

// MARK: - Tasbih Button Style

/// Custom button style for tasbih tap button with scale animation
struct TasbihButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Default State") {
    TasbihView()
        .preferredColorScheme(.dark)
}

#Preview("With Progress") {
    struct PreviewWrapper: View {
        @StateObject private var viewModel = TasbihViewModel()

        var body: some View {
            TasbihView()
                .onAppear {
                    // Simulate some progress
                    for _ in 0..<15 {
                        viewModel.increment()
                    }
                }
        }
    }

    return PreviewWrapper()
        .preferredColorScheme(.dark)
}
