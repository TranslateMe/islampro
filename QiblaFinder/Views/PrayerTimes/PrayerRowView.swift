import SwiftUI

/// Individual prayer row component for prayer times list
/// Displays prayer name, time, and countdown with visual state indicators
///
/// Design Philosophy:
/// - Typography hierarchy: Name (prominent) → Time (secondary) → Countdown (tertiary)
/// - Color coding: Green for next, gold for current, muted for passed
/// - Visual consistency: Matches compass design language (gold accents)
/// - Accessibility first: Clear labels, values, and state announcements
///
/// Visual States:
/// - isNext: Green accent background (PRIMARY_GREEN) - user's primary focus
/// - isCurrent: Gold left border (GOLD_COLOR) - prayer time happening now
/// - hasPassed: 50% opacity - de-emphasized but still readable
/// - Default: Full white - upcoming prayers
struct PrayerRowView: View {

    // MARK: - Properties

    let prayer: PrayerTimeDisplay
    @Environment(\.themeColor) private var themeColor
    @Environment(\.themeTextPrimary) private var themeTextPrimary
    @Environment(\.themeTextSecondary) private var themeTextSecondary

    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {
            // Left: Prayer names (Arabic + English)
            VStack(alignment: .leading, spacing: 4) {
                // Arabic name (primary)
                Text(prayer.arabicName)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(nameColor)

                // English name (secondary)
                Text(prayer.name)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(secondaryColor)
            }

            Spacer()

            // Right: Time + Countdown
            VStack(alignment: .trailing, spacing: 4) {
                // Prayer time (e.g., "5:42 AM")
                Text(prayer.formattedTime)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(timeColor)
                    .monospacedDigit() // Prevents width jitter

                // Countdown (e.g., "in 2h 15m")
                Text(prayer.countdown)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(countdownColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(backgroundColor)
        .overlay(leftBorder, alignment: .leading) // Current prayer indicator
        .cornerRadius(12)
        .opacity(rowOpacity)
        // Accessibility
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(accessibilityHint ?? "")
    }

    // MARK: - Computed Properties (Visual State)

    /// Background color based on state
    private var backgroundColor: Color {
        if prayer.isNext {
            // Next prayer: Green accent background
            return Color(hex: Constants.PRIMARY_GREEN).opacity(0.15)
        } else {
            // Default: Semi-transparent secondary background
            return Color("BackgroundSecondary").opacity(0.3)
        }
    }

    /// Left border for current prayer (gold)
    @ViewBuilder
    private var leftBorder: some View {
        if prayer.isCurrent {
            // Current prayer: Theme color left border
            RoundedRectangle(cornerRadius: 12)
                .fill(themeColor)
                .frame(width: 4)
        }
    }

    /// Row opacity (muted for passed prayers)
    private var rowOpacity: Double {
        prayer.hasPassed ? 0.5 : 1.0
    }

    /// Prayer name color
    private var nameColor: Color {
        if prayer.isNext {
            // Next prayer: Green accent
            return Color(hex: Constants.PRIMARY_GREEN)
        } else if prayer.isCurrent {
            // Current prayer: Theme color accent
            return themeColor
        } else {
            // Default/passed: Theme primary text
            return themeTextPrimary
        }
    }

    /// Secondary text color (English name)
    private var secondaryColor: Color {
        if prayer.isNext {
            return Color(hex: Constants.PRIMARY_GREEN).opacity(0.8)
        } else {
            return themeTextPrimary.opacity(0.7)
        }
    }

    /// Time color
    private var timeColor: Color {
        if prayer.isNext {
            return Color(hex: Constants.PRIMARY_GREEN)
        } else if prayer.isCurrent {
            return themeColor
        } else {
            return themeTextPrimary.opacity(0.9)
        }
    }

    /// Countdown color (tertiary)
    private var countdownColor: Color {
        if prayer.isNext {
            return Color(hex: Constants.PRIMARY_GREEN).opacity(0.7)
        } else {
            return themeTextSecondary
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        // Include prayer type if sunrise (not a prayer)
        if prayer.isPrayer {
            return String(format: NSLocalizedString("prayer_name_label", comment: "Prayer name label"), prayer.name)
        } else {
            return prayer.name
        }
    }

    private var accessibilityValue: String {
        // Time + countdown
        if prayer.hasPassed {
            return "\(prayer.formattedTime), \(NSLocalizedString("prayer_passed", comment: "Prayer passed label"))"
        } else {
            return "\(prayer.formattedTime), \(prayer.countdown)"
        }
    }

    private var accessibilityHint: String? {
        if prayer.isNext {
            return NSLocalizedString("next_prayer_hint", comment: "Next prayer hint")
        } else if prayer.isCurrent {
            return NSLocalizedString("current_prayer_time_hint", comment: "Current prayer time hint")
        } else {
            return nil
        }
    }
}

// MARK: - Previews
// Note: Preview code commented out temporarily due to missing .sample() method
// Previews don't affect production builds

/*
#Preview("Next Prayer - Fajr (Green)") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()

        VStack(spacing: 12) {
            PrayerRowView(
                prayer: .sample(
                    prayer: .fajr,
                    hoursFromNow: 2,
                    isNext: true,
                    isCurrent: false
                )
            )

            Text("Next prayer: Green background + green accent")
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding()
    }
}

#Preview("Current Prayer - Dhuhr (Gold Border)") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()

        VStack(spacing: 12) {
            PrayerRowView(
                prayer: .sample(
                    prayer: .dhuhr,
                    hoursFromNow: 0,
                    isNext: false,
                    isCurrent: true
                )
            )

            Text("Current prayer: Gold left border + gold text")
                .font(.caption)
                .foregroundColor(Color(hex: Constants.GOLD_COLOR))
        }
        .padding()
    }
}

#Preview("Passed Prayer - Fajr (Muted)") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()

        VStack(spacing: 12) {
            PrayerRowView(
                prayer: .sample(
                    prayer: .fajr,
                    hoursFromNow: -2,
                    isNext: false,
                    isCurrent: false
                )
            )

            Text("Passed prayer: 50% opacity, shows 'Passed'")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview("Upcoming Prayer - Asr (Default)") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()

        VStack(spacing: 12) {
            PrayerRowView(
                prayer: .sample(
                    prayer: .asr,
                    hoursFromNow: 5,
                    isNext: false,
                    isCurrent: false
                )
            )

            Text("Upcoming prayer: Clean white, no special styling")
                .font(.caption)
                .foregroundColor(Color("TextPrimary").opacity(0.7))
        }
        .padding()
    }
}

#Preview("Full Day - All States") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()

        ScrollView {
            VStack(spacing: 12) {
                // Passed
                PrayerRowView(
                    prayer: .sample(prayer: .fajr, hoursFromNow: -3, isNext: false, isCurrent: false)
                )

                // Current (gold border)
                PrayerRowView(
                    prayer: .sample(prayer: .sunrise, hoursFromNow: 0, isNext: false, isCurrent: true)
                )

                // Next (green)
                PrayerRowView(
                    prayer: .sample(prayer: .dhuhr, hoursFromNow: 2, isNext: true, isCurrent: false)
                )

                // Upcoming
                PrayerRowView(
                    prayer: .sample(prayer: .asr, hoursFromNow: 5, isNext: false, isCurrent: false)
                )

                PrayerRowView(
                    prayer: .sample(prayer: .maghrib, hoursFromNow: 8, isNext: false, isCurrent: false)
                )

                PrayerRowView(
                    prayer: .sample(prayer: .isha, hoursFromNow: 10, isNext: false, isCurrent: false)
                )
            }
            .padding()
        }
    }
}
*/
