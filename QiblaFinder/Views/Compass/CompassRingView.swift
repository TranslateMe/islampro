import SwiftUI

/// Outer compass ring - foundation for all compass elements
/// Provides the circular boundary that contains cardinal markers, Kaaba icon, and degree indicators
///
/// Visual States:
/// - NOT aligned: Dim white/gray at 30% opacity (always visible)
/// - Aligned: Green with glow effect (provides visual feedback)
struct CompassRingView: View {
    let isAligned: Bool
    @Environment(\.themeTextPrimary) private var themeTextPrimary

    var body: some View {
        Circle()
            .stroke(
                ringColor,
                lineWidth: Constants.COMPASS_RING_STROKE_WIDTH
            )
            .frame(
                width: Constants.COMPASS_RING_DIAMETER,
                height: Constants.COMPASS_RING_DIAMETER
            )
            .shadow(color: shadowColor, radius: isAligned ? 15 : 10, x: 0, y: 5)
            .accessibilityLabel("Compass ring")
            .accessibilityValue(isAligned ? "Aligned with Qibla" : "Not aligned")
    }

    /// Ring color based on alignment state
    private var ringColor: Color {
        if isAligned {
            // Aligned: Green for positive feedback
            return Color(hex: Constants.PRIMARY_GREEN)
        } else {
            // Not aligned: Dim text color at 30% opacity (always visible)
            return themeTextPrimary.opacity(0.3)
        }
    }

    /// Shadow color for glow effect
    private var shadowColor: Color {
        if isAligned {
            // Green glow when aligned
            return Color(hex: Constants.PRIMARY_GREEN).opacity(0.5)
        } else {
            // Subtle black shadow when not aligned
            return Color.black.opacity(0.1)
        }
    }
}

#Preview("Not Aligned - Dim White") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: false)
    }
}

#Preview("Aligned - Green Glow") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: true)
    }
}
