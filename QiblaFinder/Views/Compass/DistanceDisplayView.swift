import SwiftUI

/// Displays distance to Mecca and Qibla bearing below compass
/// Grouped in a semi-transparent card for clear information hierarchy
///
/// Design Philosophy:
/// - Distance is REFERENCE DATA (static context) not DYNAMIC FEEDBACK (like rotation)
/// - Updates rarely (only when location moves 50km+)
/// - NO animation (instant updates) - consistent with "data not entertainment"
/// - Gold bearing text creates visual connection to gold Kaaba pointer
/// - Card layout groups complementary information
///
/// Key Quality Decision:
/// Unlike heading (60Hz dynamic feedback), distance is static reference info.
/// This distinction drives our "no animation" choice - users glance for context,
/// they don't watch it change. The Kaaba icon provides the visual feedback.
struct DistanceDisplayView: View {
    let distance: String  // Formatted distance from ViewModel (e.g., "10,742 km")
    let bearing: String   // Formatted bearing from ViewModel (e.g., "58° NE")
    @Environment(\.themeTextPrimary) private var themeTextPrimary
    @Environment(\.themeTextSecondary) private var themeTextSecondary
    @Environment(\.themeSecondaryBackground) private var themeSecondaryBackground
    @Environment(\.themeColor) private var themeColor

    var body: some View {
        VStack(spacing: 8) {
            // Distance to Mecca section
            VStack(spacing: 2) {
                Text(NSLocalizedString("distance_to_mecca", comment: "Label for distance to Mecca"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeTextSecondary)

                Text(distance)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(themeTextPrimary)
            }

            // Qibla bearing section
            VStack(spacing: 2) {
                Text(NSLocalizedString("qibla_direction", comment: "Label for Qibla direction"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeTextSecondary)

                Text(bearing)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(themeColor)  // Theme color creates visual connection to themed elements
            }
        }
        .padding()
        .background(themeSecondaryBackground.opacity(0.6))  // Subtle card background
        .cornerRadius(16)                        // Modern, friendly corners
        // Position below compass ring with 100pt spacing
        .offset(y: Constants.COMPASS_RING_DIAMETER / 2 + 100)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(NSLocalizedString("distance_and_direction", comment: "Accessibility label for distance display"))
        .accessibilityValue(accessibilityDescription)
    }

    /// Accessibility description for VoiceOver
    private var accessibilityDescription: String {
        // Handle edge case where location is unavailable
        if distance == "--" && bearing == "--" {
            return NSLocalizedString("location_unavailable", comment: "Accessibility value when location unavailable")
        }
        return String(format: NSLocalizedString("distance_and_bearing_format", comment: "Format for distance and bearing"), distance, bearing)
    }
}

// MARK: - Previews

#Preview("Default - New York to Mecca") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)
        DistanceDisplayView(distance: "10,742 km", bearing: "58° NE")
            .overlay(
                Text("Typical display - Notice gold bearing")
                    .font(.caption)
                    .foregroundColor(.green)
                    .offset(y: 120)
            )
    }
}

#Preview("London to Mecca") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)
        DistanceDisplayView(distance: "5,234 km", bearing: "120° ESE")
            .overlay(
                Text("Different location - validates formatting")
                    .font(.caption)
                    .foregroundColor(.yellow)
                    .offset(y: 120)
            )
    }
}

#Preview("Location Unavailable - Edge Case") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)
        DistanceDisplayView(distance: "--", bearing: "--")
            .overlay(
                Text("Waiting for location data")
                    .font(.caption)
                    .foregroundColor(.red)
                    .offset(y: 120)
            )
    }
}
