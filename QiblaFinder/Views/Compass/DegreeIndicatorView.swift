import SwiftUI

/// Displays current device heading at top of compass
/// Shows both degrees (0-360) and cardinal direction (N/NE/E/SE/S/SW/W/NW)
///
/// Design Philosophy:
/// - Numbers update INSTANTLY (no animation) - they are data, not entertainment
/// - The Kaaba icon's smooth rotation provides the visual feedback
/// - Monospaced digits prevent jittery horizontal shifting
/// - Clear 3:1 hierarchy (48pt degrees / 16pt direction)
struct DegreeIndicatorView: View {
    let heading: Double  // Device heading from ViewModel (0-360)
    @Environment(\.themeTextPrimary) private var themeTextPrimary

    var body: some View {
        VStack(spacing: 4) {
            // Large degree number - primary focus
            Text(headingText)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(themeTextPrimary)
                .monospacedDigit()  // CRITICAL: Prevents width jitter as numbers change
                                    // Without this, "1" and "8" have different widths
                                    // causing horizontal shifting. Professional polish.

            // Cardinal direction - secondary info
            Text(cardinalText)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(themeTextPrimary.opacity(0.7))
        }
        // Position 80pt above compass ring
        // Provides 55pt clearance from "N" cardinal marker
        .offset(y: -(Constants.COMPASS_RING_DIAMETER / 2 + 80))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current heading")
        .accessibilityValue(accessibilityDescription)
    }

    /// Formatted heading text with degree symbol
    /// Returns "--°" if heading is undefined (NaN)
    private var headingText: String {
        if heading.isNaN {
            return "--°"
        }
        return "\(Int(heading))°"
    }

    /// Cardinal direction text (N, NE, E, SE, S, SW, W, NW)
    /// Returns "--" if heading is undefined
    private var cardinalText: String {
        if heading.isNaN {
            return "--"
        }
        return heading.cardinalDirection
    }

    /// Accessibility description for VoiceOver
    private var accessibilityDescription: String {
        if heading.isNaN {
            return "Heading unavailable"
        }
        return "\(Int(heading)) degrees \(heading.cardinalDirection)"
    }
}

// MARK: - Previews

#Preview("North - 0°") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)
        DegreeIndicatorView(heading: 0)
            .overlay(
                Text("Pointing North")
                    .font(.caption)
                    .foregroundColor(.green)
                    .offset(y: -120)
            )
    }
}

#Preview("Northwest - 285°") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)
        DegreeIndicatorView(heading: 285)
            .overlay(
                Text("Typical compass reading")
                    .font(.caption)
                    .foregroundColor(.yellow)
                    .offset(y: -120)
            )
    }
}

#Preview("Undefined Heading - Edge Case") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)
        DegreeIndicatorView(heading: .nan)
            .overlay(
                Text("Compass initializing - shows '--°'")
                    .font(.caption)
                    .foregroundColor(.red)
                    .offset(y: -120)
            )
    }
}
