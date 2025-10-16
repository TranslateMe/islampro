import SwiftUI

/// Onboarding flow for first-time users
/// 3-page swipe tutorial explaining core features
///
/// Design Philosophy:
/// - Black background (app consistency)
/// - Gold icons (brand identity)
/// - Clear feature explanations
/// - Location permission request on last page
/// - Skip button (respect user time)
/// - Show once (hasSeenOnboarding UserDefaults)
struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isPresented: Bool
    @Environment(\.themeBackground) private var themeBackground
    @Environment(\.themeTextPrimary) private var themeTextPrimary

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "location.north.circle.fill",
            title: NSLocalizedString("onboarding_compass_title", comment: "Onboarding page 1 title"),
            description: NSLocalizedString("onboarding_compass_description", comment: "Onboarding page 1 description"),
            features: [
                NSLocalizedString("onboarding_compass_feature1", comment: "Feature 1"),
                NSLocalizedString("onboarding_compass_feature2", comment: "Feature 2"),
                NSLocalizedString("onboarding_compass_feature3", comment: "Feature 3")
            ]
        ),
        OnboardingPage(
            icon: "clock.fill",
            title: NSLocalizedString("onboarding_prayer_title", comment: "Onboarding page 2 title"),
            description: NSLocalizedString("onboarding_prayer_description", comment: "Onboarding page 2 description"),
            features: [
                NSLocalizedString("onboarding_prayer_feature1", comment: "Feature 1"),
                NSLocalizedString("onboarding_prayer_feature2", comment: "Feature 2"),
                NSLocalizedString("onboarding_prayer_feature3", comment: "Feature 3")
            ]
        ),
        OnboardingPage(
            icon: "location.circle.fill",
            title: NSLocalizedString("onboarding_location_title", comment: "Onboarding page 3 title"),
            description: NSLocalizedString("onboarding_location_description", comment: "Onboarding page 3 description"),
            features: [
                NSLocalizedString("onboarding_location_feature1", comment: "Feature 1"),
                NSLocalizedString("onboarding_location_feature2", comment: "Feature 2"),
                NSLocalizedString("onboarding_location_feature3", comment: "Feature 3")
            ]
        )
    ]

    var body: some View {
        ZStack {
            // Background
            themeBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()

                    if currentPage < pages.count - 1 {
                        Button(NSLocalizedString("skip", comment: "Skip button")) {
                            HapticFeedback.light()
                            completeOnboarding()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeTextPrimary.opacity(0.7))
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                }

                // Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isLastPage: index == pages.count - 1,
                            onGetStarted: {
                                completeOnboarding()
                            }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }

    private func completeOnboarding() {
        // Mark onboarding as seen
        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.hasSeenOnboarding)

        // Dismiss
        isPresented = false

        // Request location permission if last page
        if currentPage == pages.count - 1 {
            LocationManager.shared.requestPermission()
        }
    }
}

// MARK: - Onboarding Page Data

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let features: [String]
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let onGetStarted: () -> Void
    @Environment(\.themeColor) private var themeColor
    @Environment(\.themeTextPrimary) private var themeTextPrimary

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(themeColor)
                .shadow(color: themeColor.opacity(0.3), radius: 20)

            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(themeTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Description
            Text(page.description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(themeTextPrimary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)

            // Features
            VStack(spacing: 12) {
                ForEach(page.features, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: Constants.PRIMARY_GREEN))

                        Text(feature)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeTextPrimary.opacity(0.9))

                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 60)

            Spacer()

            // Get Started button (last page only) with animation
            if isLastPage {
                Button {
                    HapticFeedback.medium()
                    onGetStarted()
                } label: {
                    Text(NSLocalizedString("get_started", comment: "Get Started button"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeColor)
                        .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            } else {
                // Swipe hint
                Text(NSLocalizedString("swipe_to_continue", comment: "Swipe hint"))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(themeTextPrimary.opacity(0.5))
                    .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(isPresented: .constant(true))
}
