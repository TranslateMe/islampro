import SwiftUI

/// Compass calibration accuracy indicator
/// Shows calibration status in top-right corner with traffic light color system
///
/// Design Philosophy:
/// - Elegant card with colored circle + text label
/// - COLOR: Traffic light metaphor (green/yellow/red) universally understood
/// - TEXT LABELS: Clear status messages ("Excellent", "Fair Accuracy", "Calibrate Compass")
/// - INTERACTIVE: Tappable when red to show calibration instructions alert
/// - SEMI-TRANSPARENT: Black background card that doesn't obstruct compass view
/// - COMPACT: Small but readable, doesn't compete with primary Kaaba icon
///
/// Quality Insight:
/// Red state is ACTIONABLE (user can fix) and provides help via tap interaction.
/// Animation prompts user action, then stops when calibrated = reward feedback.
struct AccuracyIndicatorView: View {
    let calibrationColor: Color  // From ViewModel: green/yellow/red/gray
    let isCalibrated: Bool        // From ViewModel: true when high accuracy
    let showPrompt: Bool          // From ViewModel: true only first time user sees red

    // State for calibration alert
    @State private var showCalibrationAlert = false
    @State private var isPulsing = false
    @Environment(\.themeSecondaryBackground) private var themeSecondaryBackground

    var body: some View {
        // Elegant card with circle + text label
        HStack(spacing: 8) {
            // Colored circle indicator
            Circle()
                .fill(calibrationColor)
                .frame(width: 12, height: 12)
                // Pulse animation ONLY on red (low accuracy)
                .opacity(isPulsing && calibrationColor == .red ? 0.6 : 1.0)
                .animation(
                    calibrationColor == .red
                        ? .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
                        : .none,
                    value: isPulsing
                )

            // Status text label
            Text(statusText)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(themeSecondaryBackground.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        // Position in top-right corner
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(.top, 60)      // Below notch/status bar
        .padding(.trailing, 16)  // 16pt from trailing edge
        // Make tappable when red (needs calibration)
        .onTapGesture {
            if calibrationColor == .red {
                showCalibrationAlert = true
            }
        }
        .alert(NSLocalizedString("compass_calibration", comment: "Alert title for compass calibration"), isPresented: $showCalibrationAlert) {
            Button(NSLocalizedString("ok", comment: "OK button"), role: .cancel) { }
        } message: {
            Text(NSLocalizedString("calibration_instructions", comment: "Instructions for calibrating compass"))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(NSLocalizedString("compass_calibration", comment: "Accessibility label for calibration indicator"))
        .accessibilityValue(accessibilityDescription)
        .accessibilityHint(calibrationColor == .red ? NSLocalizedString("calibration_tap_hint", comment: "Hint to tap for calibration instructions") : "")
        .onAppear {
            // Start pulse animation if red
            isPulsing = true
        }
    }

    /// Status text based on calibration color
    private var statusText: String {
        if calibrationColor == .green {
            return NSLocalizedString("excellent", comment: "Calibration status - excellent")
        } else if calibrationColor == Color(hex: "#FFC107") {
            return NSLocalizedString("fair_accuracy", comment: "Calibration status - fair")
        } else if calibrationColor == .red {
            return NSLocalizedString("calibrate_compass", comment: "Calibration status - needs calibration")
        } else {
            return NSLocalizedString("unavailable", comment: "Calibration status - unavailable")
        }
    }

    /// Text color matching calibration color
    private var textColor: Color {
        if calibrationColor == .green {
            return Color(hex: Constants.PRIMARY_GREEN)
        } else if calibrationColor == Color(hex: "#FFC107") {
            return Color(hex: "#FFC107")
        } else if calibrationColor == .red {
            return .red
        } else {
            return .gray
        }
    }

    /// Accessibility description for VoiceOver
    private var accessibilityDescription: String {
        if calibrationColor == .green {
            return NSLocalizedString("high_accuracy_calibrated", comment: "Accessibility description for excellent calibration")
        } else if calibrationColor == Color(hex: "#FFC107") {
            return NSLocalizedString("medium_accuracy_usable", comment: "Accessibility description for fair calibration")
        } else if calibrationColor == .red {
            return NSLocalizedString("low_accuracy_needs_calibration", comment: "Accessibility description for poor calibration")
        } else {
            return NSLocalizedString("compass_unavailable", comment: "Accessibility description when compass unavailable")
        }
    }
}

// MARK: - Previews

#Preview("Green - Excellent") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: true)
        CardinalMarkersView(heading: 0)
        AccuracyIndicatorView(
            calibrationColor: .green,
            isCalibrated: true,
            showPrompt: false
        )
    }
}

#Preview("Yellow - Fair Accuracy") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)
        AccuracyIndicatorView(
            calibrationColor: Color(hex: "#FFC107"),
            isCalibrated: false,
            showPrompt: false
        )
    }
}

#Preview("Red - Calibrate Compass (Tappable)") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)
        AccuracyIndicatorView(
            calibrationColor: .red,
            isCalibrated: false,
            showPrompt: true
        )
    }
}

#Preview("Gray - Unavailable") {
    ZStack {
        Color("BackgroundPrimary").ignoresSafeArea()
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)
        AccuracyIndicatorView(
            calibrationColor: .gray,
            isCalibrated: false,
            showPrompt: false
        )
    }
}
