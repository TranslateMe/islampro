import SwiftUI

/// Cardinal direction markers (N, S, E, W) positioned around the compass ring
/// These markers rotate with device heading to stay fixed to true geographic directions
/// When device points North, N marker points up; when device rotates, markers counter-rotate
struct CardinalMarkersView: View {
    let heading: Double  // Device heading in degrees (0° = North)
    @Environment(\.themeTextPrimary) private var themeTextPrimary

    var body: some View {
        let ringRadius = Constants.COMPASS_RING_DIAMETER / 2
        let markerDistance = ringRadius + 25  // 25pt outside ring edge

        ZStack {
            // North (0°, top of compass)
            Text("N")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(themeTextPrimary)
                .rotationEffect(Angle(degrees: heading))  // Keep letter upright
                .offset(x: 0, y: -markerDistance)
                .accessibilityLabel("North")

            // East (90°, right of compass)
            Text("E")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(themeTextPrimary)
                .rotationEffect(Angle(degrees: heading))  // Keep letter upright
                .offset(x: markerDistance, y: 0)
                .accessibilityLabel("East")

            // South (180°, bottom of compass)
            Text("S")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(themeTextPrimary)
                .rotationEffect(Angle(degrees: heading))  // Keep letter upright
                .offset(x: 0, y: markerDistance)
                .accessibilityLabel("South")

            // West (270°, left of compass)
            Text("W")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(themeTextPrimary)
                .rotationEffect(Angle(degrees: heading))  // Keep letter upright
                .offset(x: -markerDistance, y: 0)
                .accessibilityLabel("West")
        }
        // Counter-rotate by -heading so markers stay fixed to true geographic directions
        // When device heading changes, markers rotate opposite to stay pointing at actual N/S/E/W
        // Individual letters rotate by +heading to stay upright (double counter-rotation)
        .rotationEffect(Angle(degrees: -heading))
        .animation(.spring(response: 0.5, dampingFraction: 1.0), value: heading)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)
    }
}
