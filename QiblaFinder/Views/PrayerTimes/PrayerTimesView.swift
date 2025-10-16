import SwiftUI
import CoreLocation

/// Main prayer times screen showing all 6 daily prayers with countdowns
/// Displays location, Hijri date, and complete prayer schedule
///
/// Design Philosophy:
/// - Black background consistency (matches compass aesthetic)
/// - Clean header with location + Hijri date
/// - Automatic highlighting of next prayer (green)
/// - Live countdown updates (every second)
/// - Loading/error states with clear feedback
/// - Full accessibility support
///
/// Architecture:
/// - PrayerTimesViewModel provides reactive data
/// - Timer lifecycle managed by view (battery efficient)
/// - PrayerRowView components for each prayer
/// - Automatic updates when location/time changes
struct PrayerTimesView: View {
    @StateObject private var viewModel = PrayerTimesViewModel()
    @State private var isVisible = false
    @Environment(\.themeBackground) private var themeBackground
    @Environment(\.themeTextPrimary) private var themeTextPrimary
    @Environment(\.themeTextSecondary) private var themeTextSecondary
    @Environment(\.themeColor) private var themeColor

    var body: some View {
        ZStack {
            // Background - Uses theme background color
            themeBackground
                .ignoresSafeArea()

            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    // Header: Location + Hijri date with entrance animation
                    headerView
                        .padding(.top, 20)
                        .entranceAnimation(delay: AnimationUtilities.Delay.entrance)

                    // Prayer times list (6 prayers) with staggered animations
                    if viewModel.hasPrayerTimes {
                        prayerListView
                    } else if !viewModel.isLoading {
                        // Skeleton loading placeholders while prayer times are being calculated
                        skeletonLoadingView
                    }
                }
                .padding(.horizontal, 20)
            }

            // Loading overlay (topmost, z-index 999)
            if viewModel.isLoading {
                loadingOverlay
                    .zIndex(999)
                    .transition(AnimationUtilities.scaleFadeTransition)
            }
        }
        // Entrance animation (fade in)
        .opacity(isVisible ? 1.0 : 0.0)
        // Lifecycle management
        .onAppear {
            withAnimation(AnimationUtilities.Spring.gentle) {
                isVisible = true
            }
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        // Accessibility
        .accessibilityElement(children: .contain)
    }

    // MARK: - Header View

    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 12) {
            // Location name
            if let location = LocationManager.shared.currentLocation {
                // TODO: Reverse geocoding for city name (future enhancement)
                // For now, show coordinates in readable format
                Text(locationText(for: location))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(themeTextPrimary.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            // Hijri date (e.g., "15 Ramadan 1446")
            if !viewModel.hijriDate.isEmpty {
                Text(viewModel.hijriDate)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: Constants.GOLD_COLOR))
                    .accessibilityLabel(String(format: NSLocalizedString("islamic_date_label", comment: "Islamic date label"), viewModel.hijriDate))
            }

            // Divider
            Rectangle()
                .fill(themeTextPrimary.opacity(0.2))
                .frame(height: 1)
                .frame(maxWidth: 200)
                .padding(.top, 8)
        }
    }

    // MARK: - Prayer List View

    @ViewBuilder
    private var prayerListView: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.prayerTimes.enumerated()), id: \.element.id) { index, prayer in
                PrayerRowView(prayer: prayer)
                    .staggeredEntrance(index: index)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(NSLocalizedString("prayer_times_list_label", comment: "Prayer times list label"))
    }

    // MARK: - Skeleton Loading View

    @ViewBuilder
    private var skeletonLoadingView: some View {
        VStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                HStack(spacing: 16) {
                    // Prayer name placeholder
                    SkeletonView(width: 80, height: 20, cornerRadius: 8)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        // Time placeholder
                        SkeletonView(width: 70, height: 20, cornerRadius: 8)

                        // Countdown placeholder
                        SkeletonView(width: 100, height: 16, cornerRadius: 6)
                    }
                }
                .padding()
                .background(
                    Color("BackgroundPrimary")
                        .opacity(0.05)
                )
                .cornerRadius(12)
                .staggeredEntrance(index: index)
            }
        }
    }

    // MARK: - Loading Overlay

    @ViewBuilder
    private var loadingOverlay: some View {
        ZStack {
            // Semi-transparent blur background
            Color("BackgroundPrimary").opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Loading indicator
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(themeTextPrimary)

                // Status message
                Text(viewModel.statusMessage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeTextPrimary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Error state: "Open Settings" button (when permissions denied)
                if let error = viewModel.errorMessage,
                   error.contains("denied") || error.contains("restricted") {
                    Button {
                        HapticFeedback.medium()
                        openSettings()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                            Text(NSLocalizedString("open_settings", comment: "Open Settings button"))
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("BackgroundPrimary"))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(themeTextPrimary)
                        .cornerRadius(12)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Helper Methods

    /// Format location for display
    private func locationText(for location: CLLocation) -> String {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        // Format coordinates with direction (e.g., "40.71°N, 74.01°W")
        let latDirection = lat >= 0 ? "N" : "S"
        let lonDirection = lon >= 0 ? "E" : "W"

        return String(format: "%.2f°%@ %.2f°%@",
                     abs(lat), latDirection,
                     abs(lon), lonDirection)
    }

    /// Opens iOS Settings app
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Previews
// Note: Preview code commented out temporarily due to missing sample data methods
// Previews don't affect production builds

/*
#Preview("Default State - With Prayer Times") {
    // Create view with sample data
    struct SamplePreview: View {
        @StateObject private var viewModel = PrayerTimesViewModel()

        var body: some View {
            ZStack {
                Color("BackgroundPrimary").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("40.71°N 74.01°W")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color("TextPrimary").opacity(0.8))

                            Text("15 Ramadan 1446")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(Color(hex: Constants.GOLD_COLOR))

                            Rectangle()
                                .fill(Color("TextPrimary").opacity(0.2))
                                .frame(height: 1)
                                .frame(maxWidth: 200)
                                .padding(.top, 8)
                        }
                        .padding(.top, 20)

                        // Prayer list (using sample data)
                        VStack(spacing: 12) {
                            ForEach(PrayerTimeDisplay.sampleDay) { prayer in
                                PrayerRowView(prayer: prayer)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    return SamplePreview()
}
*/

#Preview("Loading State") {
    struct LoadingPreview: View {
        var body: some View {
            ZStack {
                Color("BackgroundPrimary").ignoresSafeArea()

                ZStack {
                    Color("BackgroundPrimary").opacity(0.7)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color("TextPrimary"))

                        Text("Calculating prayer times...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("TextPrimary").opacity(0.9))
                    }
                }
                .zIndex(999)
            }
        }
    }

    return LoadingPreview()
}

#Preview("Error State - Permission Denied") {
    struct ErrorPreview: View {
        var body: some View {
            ZStack {
                Color("BackgroundPrimary").ignoresSafeArea()

                ZStack {
                    Color("BackgroundPrimary").opacity(0.7)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color("TextPrimary"))

                        Text("Location permission denied")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("TextPrimary").opacity(0.9))

                        Button {
                            // Preview only
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "gearshape.fill")
                                Text("Open Settings")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("BackgroundPrimary"))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color("TextPrimary"))
                            .cornerRadius(12)
                        }
                    }
                }
                .zIndex(999)
            }
        }
    }

    return ErrorPreview()
}
