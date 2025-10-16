import SwiftUI

/// Permission request view for location access
/// Shows when user has denied location permission
///
/// Design Philosophy:
/// - Respectful, not pushy (clear explanation, no pressure)
/// - Red icon for attention (indicates blocked state)
/// - Black background (app consistency)
/// - Professional spacing and typography
/// - Direct path to fix (Settings button)
/// - Educational (explains why location is needed)
///
/// UX Principles:
/// - Explain the "why" before asking (builds trust)
/// - Make it easy to fix (direct Settings link)
/// - Don't block other features (only show where needed)
/// - One clear action (no confusion)
struct PermissionView: View {
    @Environment(\.themeBackground) private var themeBackground
    @Environment(\.themeTextPrimary) private var themeTextPrimary
    @Environment(\.themeTextSecondary) private var themeTextSecondary

    var body: some View {
        ZStack {
            // Background
            themeBackground.ignoresSafeArea()

            // Content
            VStack(spacing: 32) {
                Spacer()

                // Icon (red for blocked/denied state)
                Image(systemName: "location.slash.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                    .shadow(color: .red.opacity(0.3), radius: 20)

                // Title
                Text("Location Access Required")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(themeTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Explanation
                Text("QiblaFinder needs your location to determine the accurate Qibla direction. Please enable location access in Settings.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(themeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)

                // Open Settings button with animation
                Button {
                    HapticFeedback.medium()
                    openSettings()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))

                        Text("Open Settings")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 40)
                .padding(.top, 8)

                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Location access required")
        .accessibilityHint("Enable location access in Settings to use QiblaFinder")
    }

    /// Opens iOS Settings app
    /// Uses UIApplication.openSettingsURLString to navigate directly to app settings
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview

#Preview("Permission Denied") {
    PermissionView()
}

#Preview("With Tab Bar Context") {
    // Show how it looks within the app
    TabView {
        PermissionView()
            .tabItem {
                Label("Qibla", systemImage: "location.north.circle.fill")
            }
    }
}
