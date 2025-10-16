import SwiftUI

/// Error view for GPS signal issues
/// Shows when location permission is granted but GPS signal is weak/unavailable
///
/// Design Philosophy:
/// - Orange icon for warning (not as severe as red denial)
/// - Informative about cache usage (transparency)
/// - Actionable with retry button
/// - Black background (app consistency)
/// - Professional spacing and typography
///
/// UX Principles:
/// - Show what's happening (using cache if available)
/// - Provide context (timestamp of cached data)
/// - Give user control (retry button)
/// - Don't alarm (orange warning, not red error)
struct ErrorView: View {
    let cachedTimestamp: Date?
    let onRetry: () -> Void
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

                // Icon (orange for warning)
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .shadow(color: .orange.opacity(0.3), radius: 15)

                // Title
                Text("GPS Signal Weak")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(themeTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Status message (with cache info if available)
                VStack(spacing: 12) {
                    if let timestamp = cachedTimestamp {
                        // Show cached location info
                        Text("Using last known location from")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(themeTextSecondary)
                            .multilineTextAlignment(.center)

                        Text(formattedTimestamp(timestamp))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    } else {
                        // No cache available
                        Text("No location available. Please ensure Location Services are enabled.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(themeTextSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)

                // Retry button with animation
                Button {
                    HapticFeedback.light()
                    onRetry()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18))

                        Text("Retry")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
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
        .accessibilityLabel("GPS signal weak")
        .accessibilityValue(accessibilityDescription)
        .accessibilityHint("Tap retry to request fresh location")
    }

    /// Format timestamp for display
    /// Shows relative time if recent (e.g., "5 minutes ago")
    /// Shows absolute time if older (e.g., "Today at 2:30 PM")
    private func formattedTimestamp(_ timestamp: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(timestamp)

        // Less than 1 hour: show relative time
        if interval < 3600 {
            let minutes = Int(interval / 60)
            if minutes < 1 {
                return "just now"
            } else if minutes == 1 {
                return "1 minute ago"
            } else {
                return "\(minutes) minutes ago"
            }
        }

        // Less than 24 hours: show "Today at HH:MM"
        if interval < 86400 {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today at \(formatter.string(from: timestamp))"
        }

        // Less than 48 hours: show "Yesterday at HH:MM"
        if interval < 172800 {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Yesterday at \(formatter.string(from: timestamp))"
        }

        // Older: show full date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    /// Accessibility description
    private var accessibilityDescription: String {
        if let timestamp = cachedTimestamp {
            return "Using cached location from \(formattedTimestamp(timestamp))"
        } else {
            return "No location available"
        }
    }
}

// MARK: - Preview

#Preview("With Cached Location - Recent") {
    ErrorView(
        cachedTimestamp: Date().addingTimeInterval(-600), // 10 minutes ago
        onRetry: { print("Retry tapped") }
    )
}

#Preview("With Cached Location - Today") {
    ErrorView(
        cachedTimestamp: Date().addingTimeInterval(-7200), // 2 hours ago
        onRetry: { print("Retry tapped") }
    )
}

#Preview("With Cached Location - Yesterday") {
    ErrorView(
        cachedTimestamp: Date().addingTimeInterval(-90000), // 25 hours ago
        onRetry: { print("Retry tapped") }
    )
}

#Preview("No Cache Available") {
    ErrorView(
        cachedTimestamp: nil,
        onRetry: { print("Retry tapped") }
    )
}
