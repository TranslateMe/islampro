import SwiftUI

/// Main compass view that assembles all compass components
/// This is the primary view for displaying the Qibla compass
///
/// Design Philosophy - Final Assembly:
/// - MINIMAL entrance animation - very subtle fade (0.2s) for polish without delay
/// - Solid black background - classic compass style, maximum contrast
/// - Proper z-index layering - loading overlay always on top
/// - Graceful edge case handling - clear feedback for all states
/// - Full accessibility - VoiceOver announcements for alignment
///
/// Component Layering (Bottom to Top):
/// 1. Background (black)
/// 2. Compass Ring
/// 3. Cardinal Markers (N/S/E/W)
/// 4. Kaaba Icon (rotating) - PRIMARY element
/// 5. Alignment Glow (conditional)
/// 6. Degree Indicator (top)
/// 7. Distance Display (bottom)
/// 8. Accuracy Indicator (corner)
/// 9. Permission Denied Overlay (z-index 1000, highest priority)
/// 10. GPS Error Overlay (z-index 998, when signal weak)
/// 11. Loading Overlay (z-index 999, when actively loading)
struct CompassView: View {
    @StateObject private var viewModel = CompassViewModel()
    @StateObject private var locationManager = LocationManager.shared
    @State private var isVisible = false
    @Environment(\.themeBackground) private var themeBackground
    @Environment(\.themeTextPrimary) private var themeTextPrimary

    /// Determines if GPS error view should be shown
    /// Shows when:
    /// - Permission is granted (not denied or restricted)
    /// - Location error exists (GPS unavailable)
    /// - Not actively loading (loading overlay takes priority)
    private var shouldShowGPSError: Bool {
        // Don't show if permission denied (PermissionView handles that)
        guard !viewModel.locationStatus.contains("denied") else {
            return false
        }

        // Don't show while actively loading (Loading overlay handles that)
        guard !viewModel.isLoading else {
            return false
        }

        // Show if we have a location error
        if locationManager.error != nil {
            return true
        }

        // Show if no location after a reasonable time (cache is stale and no fresh location)
        if viewModel.userLocation == nil && locationManager.isCacheStale() {
            return true
        }

        return false
    }

    var body: some View {
        ZStack {
            // Layer 1: Background - Uses theme background color
            // No gradient, no animation - maximum contrast for Kaaba icon
            themeBackground
                .ignoresSafeArea()

            // Layers 2-8: Compass components
            // Grouped for accessibility and proper ordering
            ZStack {
                // Layer 2: Basic compass ring (always visible, changes color when aligned)
                CompassRingView(isAligned: viewModel.isAligned)

                // Layer 3: Cardinal markers (N/S/E/W) - rotate to stay fixed to true geographic directions
                CardinalMarkersView(heading: viewModel.deviceHeading)

                // Layer 4: Kaaba icon pointer (PRIMARY element)
                // Golden arrow that rotates to point toward Mecca
                // Smooth spring animation, gradient styling, 50pt size
                KaabaIconView(
                    rotation: viewModel.relativeBearing,
                    isAligned: viewModel.isAligned
                )

                // Layer 5: Alignment glow (when pointing at Mecca)
                // Green circle around Kaaba icon when within 5° of Qibla
                // Appears behind degree/distance displays for proper layering
                // Pulse animation draws attention to alignment
                if viewModel.isAligned {
                    Circle()
                        .stroke(Color.green, lineWidth: 4)
                        .frame(
                            width: Constants.COMPASS_RING_DIAMETER + 10,
                            height: Constants.COMPASS_RING_DIAMETER + 10
                        )
                        .shadow(color: .green, radius: 20)
                        .opacity(0.8)
                        .pulse(isActive: true)
                        .transition(.scale.combined(with: .opacity))
                }

                // Layer 6: Degree indicator (top)
                // Shows current device heading (e.g., "285° NW")
                // 48pt with .monospacedDigit() - no jitter, instant updates
                DegreeIndicatorView(heading: viewModel.deviceHeading)

                // Layer 7: Distance to Mecca display (bottom)
                // Shows distance + Qibla bearing in semi-transparent card
                // Gold bearing text creates visual connection to gold Kaaba icon
                // Reference data (updates rarely) - no animation
                DistanceDisplayView(
                    distance: viewModel.distanceToMecca,
                    bearing: viewModel.bearingText
                )

                // Layer 8: Accuracy indicator (top-right corner)
                // Traffic light color system (green/yellow/red/gray)
                // Gentle pulse on red only (ACTIONABLE feedback)
                // Progressive disclosure prompt with UserDefaults
                AccuracyIndicatorView(
                    calibrationColor: viewModel.calibrationColor,
                    isCalibrated: viewModel.isCalibrated,
                    showPrompt: viewModel.showCalibrationPrompt
                )
            }
            .accessibilityElement(children: .contain)  // Group compass components for VoiceOver

            // Layer 9: Permission denied overlay (highest priority)
            // Shows PermissionView when location access is denied
            // Full-screen, respectful design with clear call-to-action
            if viewModel.locationStatus.contains("denied") {
                PermissionView()
                    .zIndex(1000)  // Highest priority
                    .transition(AnimationUtilities.scaleFadeTransition)
            }

            // Layer 10: GPS Error overlay (second priority)
            // Shows ErrorView when GPS signal is weak but permission granted
            // Displays cached location info if available with retry option
            if shouldShowGPSError {
                ErrorView(
                    cachedTimestamp: locationManager.cachedLocationTimestamp,
                    onRetry: {
                        locationManager.requestLocation()
                        HapticFeedback.light()
                    }
                )
                .zIndex(998)  // Below permission denied, above loading
                .transition(AnimationUtilities.scaleFadeTransition)
            }

            // Layer 11: Loading overlay (when actively loading)
            // Semi-transparent blur background
            // Shows while locating or initializing
            // Lower priority than permission denied
            if viewModel.isLoading && !viewModel.locationStatus.contains("denied") {
                ZStack {
                    // Blur background
                    themeBackground.opacity(0.7)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        // Loading indicator with smooth appearance
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(themeTextPrimary)

                        // Status message
                        Text(viewModel.locationStatus)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeTextPrimary.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                .zIndex(999)  // Second highest priority
                .transition(.opacity)
                .accessibilityElement(children: .combine)
            }
        }
        // Minimal entrance animation (0.2s) - fast access while adding polish
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                isVisible = true
            }
            viewModel.startCompass()
        }
        .onDisappear {
            viewModel.stopCompass()
        }
        // Accessibility: Announce when aligned with Qibla
        .onChange(of: viewModel.isAligned) { oldValue, newValue in
            // Announce only when alignment is achieved (false → true)
            if !oldValue && newValue {
                announceAlignment()
                HapticFeedback.success()
            }
        }
    }

    /// Announces "Aligned with Qibla" to VoiceOver users
    /// Called when isAligned changes from false to true
    /// Triggers success haptic feedback for tactile confirmation
    private func announceAlignment() {
        UIAccessibility.post(
            notification: .announcement,
            argument: NSLocalizedString("aligned_with_qibla", comment: "VoiceOver announcement when compass is aligned with Qibla")
        )
    }
}

// MARK: - Previews

#Preview("Default State - New York") {
    CompassView()
}

#Preview("Loading State") {
    // Create view with loading state
    struct LoadingPreview: View {
        @StateObject private var viewModel = CompassViewModel()

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                if true {  // Simulate loading
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)

                            Text("Locating...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .zIndex(999)
                }
            }
        }
    }

    return LoadingPreview()
}

#Preview("Permission Denied - PermissionView") {
    // Shows the new PermissionView overlay
    ZStack {
        Color.black.ignoresSafeArea()

        // Compass components (background)
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)

        // PermissionView overlay
        PermissionView()
            .zIndex(1000)
    }
}

#Preview("GPS Error - With Cached Location") {
    // Shows GPS error with cached location timestamp
    ZStack {
        Color.black.ignoresSafeArea()

        // Compass components (background)
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)

        // ErrorView overlay
        ErrorView(
            cachedTimestamp: Date().addingTimeInterval(-3600), // 1 hour ago
            onRetry: { print("Retry tapped") }
        )
        .zIndex(998)
    }
}

#Preview("GPS Error - No Cache") {
    // Shows GPS error without cached location
    ZStack {
        Color.black.ignoresSafeArea()

        // Compass components (background)
        CompassRingView(isAligned: false)
        CardinalMarkersView(heading: 0)

        // ErrorView overlay
        ErrorView(
            cachedTimestamp: nil,
            onRetry: { print("Retry tapped") }
        )
        .zIndex(998)
    }
}
