import SwiftUI
import MapKit
import CoreLocation

/// Map view showing user location and route to Mecca
/// Visualizes geographic connection between user and Qibla direction
///
/// Design Philosophy:
/// - Visual geographic context (see the distance/direction)
/// - Gold Mecca marker (matches app color scheme)
/// - Geodesic line showing Qibla direction
/// - Distance overlay (quick reference)
/// - Automatic camera positioning (elegant framing)
/// - Loading states (graceful when no location)
/// - Heading indicator (shows which direction user is facing)
/// - Facing direction cone (blue arc showing user's view direction)
///
/// Features:
/// - User location (blue dot - built-in MapKit)
/// - Mecca annotation (gold custom marker)
/// - Geodesic line (great circle route)
/// - Distance info card (overlay)
/// - Auto-zoom to show both points
/// - Heading indicator (compass arrow)
/// - Facing direction cone (blue arc)
struct MapView: View {
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var compassManager = CompassManager.shared
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isVisible = false
    @Environment(\.themeBackground) private var themeBackground
    @Environment(\.themeSecondaryBackground) private var themeSecondaryBackground
    @Environment(\.themeTextPrimary) private var themeTextPrimary
    @Environment(\.themeTextSecondary) private var themeTextSecondary
    @Environment(\.themeColor) private var themeColor

    // Mecca location constant
    private let meccaLocation = CLLocationCoordinate2D(
        latitude: Constants.MECCA_LATITUDE,
        longitude: Constants.MECCA_LONGITUDE
    )

    var body: some View {
        ZStack {
            // Map with entrance animation
            if let userLocation = locationManager.currentLocation {
                Map(position: $cameraPosition) {
                    // User location (blue dot - automatic)
                    UserAnnotation()

                    // Mecca annotation (gold marker)
                    Annotation(NSLocalizedString("mecca", comment: "Mecca city name"), coordinate: meccaLocation) {
                        ZStack {
                            // Gold circle background
                            Circle()
                                .fill(themeColor)
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                            // Kaaba icon
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeTextPrimary)
                        }
                    }

                    // Geodesic line from user to Mecca
                    MapPolyline(coordinates: [
                        userLocation.coordinate,
                        meccaLocation
                    ])
                    .stroke(Color(hex: Constants.PRIMARY_GREEN), lineWidth: 3)

                    // Facing direction cone (blue arc showing user's view direction)
                    if compassManager.isAvailable {
                        MapPolyline(coordinates: headingConeCoordinates(for: userLocation))
                            .stroke(Color.blue.opacity(0.4), lineWidth: 2)

                        // Heading indicator annotation (arrow showing facing direction)
                        Annotation("", coordinate: userLocation.coordinate) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(compassManager.heading))
                                .shadow(color: .black.opacity(0.3), radius: 2)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .onAppear {
                    // Entrance animation: zoom in smoothly
                    withAnimation(AnimationUtilities.Spring.smooth.delay(0.1)) {
                        isVisible = true
                    }
                    updateCamera(for: userLocation)
                    // Start compass updates for heading indicator
                    compassManager.startUpdating()
                }
                .onDisappear {
                    // Stop compass updates to save battery
                    compassManager.stopUpdating()
                }
                .onChange(of: userLocation) { oldValue, newValue in
                    updateCamera(for: newValue)
                }
                .scaleEffect(isVisible ? 1.0 : 0.9)
                .opacity(isVisible ? 1.0 : 0.0)

                // Distance info overlay (top center) with entrance animation
                VStack {
                    distanceCard(for: userLocation)
                        .padding(.top, 60)
                        .entranceAnimation(delay: AnimationUtilities.Delay.entrance + 0.2)

                    Spacer()
                }
            } else {
                // Loading state (no location yet) with smooth animation
                Color("BackgroundPrimary").ignoresSafeArea()

                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(themeTextPrimary)

                    Text(NSLocalizedString("loading_location", comment: "Loading location message"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeTextPrimary.opacity(0.9))
                }
                .entranceAnimation()
            }
        }
        // Accessibility
        .accessibilityElement(children: .contain)
        .accessibilityLabel(NSLocalizedString("map_route_to_mecca", comment: "Map accessibility label"))
    }

    // MARK: - Distance Card Overlay

    @ViewBuilder
    private func distanceCard(for location: CLLocation) -> some View {
        let qibla = QiblaCalculator.calculateQibla(from: location)

        HStack(spacing: 12) {
            // Icon
            Image(systemName: "arrow.forward.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(themeColor)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("distance_to_mecca", comment: "Distance to Mecca label"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeTextSecondary)

                Text(qibla.formattedDistance)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(themeTextPrimary)

                Text(qibla.formattedBearing)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(themeColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeSecondaryBackground.opacity(0.95))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: NSLocalizedString("map_distance_direction_label", comment: "Map distance and direction"), qibla.formattedDistance, qibla.formattedBearing))
    }

    // MARK: - Camera Positioning

    private func updateCamera(for userLocation: CLLocation) {
        // Calculate bounds to show both user and Mecca
        let userCoord = userLocation.coordinate
        let meccaCoord = meccaLocation

        // Find center point
        let centerLat = (userCoord.latitude + meccaCoord.latitude) / 2
        let centerLon = (userCoord.longitude + meccaCoord.longitude) / 2
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)

        // Calculate span to show both points with padding
        let latDelta = abs(userCoord.latitude - meccaCoord.latitude) * 1.5
        let lonDelta = abs(userCoord.longitude - meccaCoord.longitude) * 1.5

        // Create region
        let span = MKCoordinateSpan(latitudeDelta: max(latDelta, 10), longitudeDelta: max(lonDelta, 10))
        let region = MKCoordinateRegion(center: center, span: span)

        // Update camera with animation
        withAnimation(.easeInOut(duration: 1.0)) {
            cameraPosition = .region(region)
        }
    }

    // MARK: - Heading Cone Calculation

    /// Calculate coordinates for the facing direction cone (blue arc)
    /// Creates a fan/cone shape showing where the user is looking
    /// Parameters:
    /// - location: User's current location
    /// - coneAngle: Width of the cone in degrees (default 45°)
    /// - coneLength: Length of the cone in meters (default 500km)
    private func headingConeCoordinates(for location: CLLocation, coneAngle: Double = 45, coneLength: Double = 500000) -> [CLLocationCoordinate2D] {
        let heading = compassManager.heading
        let userCoord = location.coordinate

        var coordinates: [CLLocationCoordinate2D] = []

        // Start at user location
        coordinates.append(userCoord)

        // Create arc points (cone edges)
        let startAngle = heading - (coneAngle / 2)
        let endAngle = heading + (coneAngle / 2)

        // Generate points along the arc
        let steps = 20
        for i in 0...steps {
            let angle = startAngle + (endAngle - startAngle) * Double(i) / Double(steps)
            let coord = coordinate(from: userCoord, atDistance: coneLength, bearing: angle)
            coordinates.append(coord)
        }

        // Close the cone back to user location
        coordinates.append(userCoord)

        return coordinates
    }

    /// Calculate a coordinate at a given distance and bearing from a starting point
    /// Uses the Haversine formula for great circle calculations
    private func coordinate(from start: CLLocationCoordinate2D, atDistance distance: Double, bearing: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6371000.0 // Earth's radius in meters

        // Convert to radians
        let lat1 = start.latitude * .pi / 180
        let lon1 = start.longitude * .pi / 180
        let bearingRad = bearing * .pi / 180

        // Calculate new position
        let lat2 = asin(sin(lat1) * cos(distance / earthRadius) +
                       cos(lat1) * sin(distance / earthRadius) * cos(bearingRad))

        let lon2 = lon1 + atan2(sin(bearingRad) * sin(distance / earthRadius) * cos(lat1),
                               cos(distance / earthRadius) - sin(lat1) * sin(lat2))

        // Convert back to degrees
        return CLLocationCoordinate2D(
            latitude: lat2 * 180 / .pi,
            longitude: lon2 * 180 / .pi
        )
    }
}

// MARK: - Previews

#Preview("Map with Location") {
    // Simulate New York location
    struct PreviewWrapper: View {
        @StateObject private var locationManager = LocationManager.shared

        var body: some View {
            MapView()
                .onAppear {
                    // Simulate location for preview
                    let nyLocation = CLLocation(
                        latitude: 40.7128,
                        longitude: -74.0060
                    )
                    locationManager.currentLocation = nyLocation
                }
        }
    }

    return PreviewWrapper()
}

#Preview("Loading State") {
    struct LoadingPreview: View {
        var body: some View {
            ZStack {
                Color("BackgroundPrimary").ignoresSafeArea()

                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color("TextPrimary"))

                    Text("Loading location...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TextPrimary").opacity(0.9))
                }
            }
        }
    }

    return LoadingPreview()
}
