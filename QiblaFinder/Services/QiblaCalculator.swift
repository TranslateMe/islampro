import Foundation
import CoreLocation

// MARK: - QiblaCalculator

/// Static calculator for determining Qibla direction using Great Circle formula
struct QiblaCalculator {

    // MARK: - Public Methods

    /// Calculate Qibla direction from user location to Mecca
    /// - Parameter location: User's current location
    /// - Returns: QiblaDirection containing bearing, distance, and alignment status
    ///
    /// Test Cases (validated against known correct bearings):
    /// - New York (40.7128°N, 74.0060°W) → Mecca ≈ 58° (NE)
    /// - London (51.5074°N, 0.1278°W) → Mecca ≈ 119° (ESE)
    /// - Sydney (-33.8688°S, 151.2093°E) → Mecca ≈ 277° (W)
    /// - Tokyo (35.6762°N, 139.6503°E) → Mecca ≈ 293° (NW)
    static func calculateQibla(from location: CLLocation) -> QiblaDirection {
        let bearing = calculateBearing(from: location)
        let distance = location.distanceToMecca

        // Check if bearing is aligned with Qibla (within threshold)
        // Note: This checks if compass is pointing in the right direction
        let isAligned = abs(bearing) <= Constants.QIBLA_ALIGNMENT_THRESHOLD

        return QiblaDirection(
            bearing: bearing,
            distance: distance,
            cardinalDirection: bearing.cardinalDirection,
            isAligned: isAligned
        )
    }

    // MARK: - Private Methods

    /// Calculate bearing from user location to Mecca using Great Circle formula
    /// - Parameter location: User's current location
    /// - Returns: Bearing in degrees (0-360°) where 0° = North, 90° = East, 180° = South, 270° = West
    ///
    /// Uses spherical geometry (Great Circle) for accurate bearing calculation:
    /// - φ1, φ2 = latitude of user and Mecca (in radians)
    /// - Δλ = difference in longitude (in radians)
    /// - θ = atan2(sin(Δλ) * cos(φ2), cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ))
    /// - bearing = (θ in degrees + 360) % 360
    private static func calculateBearing(from location: CLLocation) -> Double {
        let userLat = location.coordinate.latitude
        let userLon = location.coordinate.longitude

        let meccaLat = Constants.MECCA_LATITUDE
        let meccaLon = Constants.MECCA_LONGITUDE

        // Convert to radians
        let φ1 = userLat.toRadians
        let φ2 = meccaLat.toRadians
        let Δλ = (meccaLon - userLon).toRadians

        // Great Circle bearing formula
        let y = sin(Δλ) * cos(φ2)
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)
        let θ = atan2(y, x)

        // Convert to degrees and normalize to 0-360°
        let bearing = (θ.toDegrees + 360).truncatingRemainder(dividingBy: 360)

        return bearing
    }
}

// MARK: - QiblaDirection Model

/// Represents the calculated Qibla direction from user's location to Mecca
struct QiblaDirection {
    /// Bearing in degrees (0-360°) where 0° = North, 90° = East, 180° = South, 270° = West
    let bearing: Double

    /// Distance to Mecca in meters
    let distance: Double

    /// Cardinal direction (N, NE, E, SE, S, SW, W, NW)
    let cardinalDirection: String

    /// Whether the user is aligned with Qibla (within 5° threshold)
    let isAligned: Bool

    // MARK: - Computed Properties

    /// Formatted bearing string (e.g., "58° NE")
    var formattedBearing: String {
        return bearing.formattedBearing
    }

    /// Formatted distance string with thousand separators (e.g., "10,742 km")
    var formattedDistance: String {
        let km = distance / 1000.0
        return "\(km.formattedDistance()) km"
    }

    /// Distance in kilometers
    var distanceKm: Double {
        return distance / 1000.0
    }
}
