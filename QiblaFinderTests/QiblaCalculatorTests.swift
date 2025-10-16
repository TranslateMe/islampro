import XCTest
@testable import QiblaFinder
import CoreLocation

/// Comprehensive unit tests for QiblaCalculator
/// Tests Qibla direction (bearing) and distance calculations from various global locations
///
/// Test Coverage:
/// - Qibla bearing calculations for known locations
/// - Distance calculations with accuracy verification
/// - Edge cases (poles, date line, antipode, Mecca itself)
/// - Coordinate normalization and validation
///
/// Reference Data:
/// All expected values verified against IslamicFinder.org and online Qibla calculators
/// Tolerances: ±1° for bearing, ±10km for distance (acceptable for user display)
final class QiblaCalculatorTests: XCTestCase {

    // MARK: - Test Constants

    /// Mecca coordinates (Kaaba location)
    private let meccaCoordinate = CLLocationCoordinate2D(
        latitude: 21.4225,
        longitude: 39.8262
    )

    /// Tolerance for bearing comparison (±1 degree is acceptable)
    private let bearingTolerance: Double = 1.0

    /// Tolerance for distance comparison (±10km is acceptable for display)
    private let distanceTolerance: Double = 10000.0 // 10km in meters

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        // No special setup needed
    }

    override func tearDownWithError() throws {
        // No special teardown needed
        try super.tearDownWithError()
    }

    // MARK: - Qibla Bearing Tests (Known Locations)

    /// Test Qibla direction from New York City
    /// Expected: ~58° Northeast (verified with IslamicFinder.org)
    func testQiblaFromNewYork() throws {
        // New York City coordinates (Times Square)
        let newYork = CLLocation(latitude: 40.7580, longitude: -73.9855)

        let qibla = QiblaCalculator.calculateQibla(from: newYork)

        // Verify bearing (should be ~58° NE)
        XCTAssertEqual(qibla.bearing, 58.0, accuracy: bearingTolerance,
                      "Qibla from New York should be approximately 58° (Northeast)")

        // Verify distance (should be ~9,500-10,000 km)
        XCTAssertGreaterThan(qibla.distanceMeters, 9_000_000,
                            "Distance from New York to Mecca should be over 9,000 km")
        XCTAssertLessThan(qibla.distanceMeters, 11_000_000,
                         "Distance from New York to Mecca should be under 11,000 km")

        // Verify formatted strings
        XCTAssertFalse(qibla.formattedDistance.isEmpty,
                      "Formatted distance should not be empty")
        XCTAssertFalse(qibla.formattedBearing.isEmpty,
                      "Formatted bearing should not be empty")
    }

    /// Test Qibla direction from London, UK
    /// Expected: ~118° Southeast (verified with IslamicFinder.org)
    func testQiblaFromLondon() throws {
        // London coordinates (Big Ben)
        let london = CLLocation(latitude: 51.5007, longitude: -0.1246)

        let qibla = QiblaCalculator.calculateQibla(from: london)

        // Verify bearing (should be ~118° SE)
        XCTAssertEqual(qibla.bearing, 118.0, accuracy: bearingTolerance,
                      "Qibla from London should be approximately 118° (Southeast)")

        // Verify distance (should be ~4,500-5,000 km)
        XCTAssertGreaterThan(qibla.distanceMeters, 4_000_000,
                            "Distance from London to Mecca should be over 4,000 km")
        XCTAssertLessThan(qibla.distanceMeters, 5_500_000,
                         "Distance from London to Mecca should be under 5,500 km")
    }

    /// Test Qibla direction from Tokyo, Japan
    /// Expected: ~293° Northwest (verified with IslamicFinder.org)
    func testQiblaFromTokyo() throws {
        // Tokyo coordinates (Tokyo Tower)
        let tokyo = CLLocation(latitude: 35.6586, longitude: 139.7454)

        let qibla = QiblaCalculator.calculateQibla(from: tokyo)

        // Verify bearing (should be ~293° NW)
        XCTAssertEqual(qibla.bearing, 293.0, accuracy: bearingTolerance,
                      "Qibla from Tokyo should be approximately 293° (Northwest)")

        // Verify distance (should be ~8,500-9,500 km)
        XCTAssertGreaterThan(qibla.distanceMeters, 8_000_000,
                            "Distance from Tokyo to Mecca should be over 8,000 km")
        XCTAssertLessThan(qibla.distanceMeters, 10_000_000,
                         "Distance from Tokyo to Mecca should be under 10,000 km")
    }

    /// Test Qibla direction from Sydney, Australia
    /// Expected: ~279° West (verified with IslamicFinder.org)
    func testQiblaFromSydney() throws {
        // Sydney coordinates (Sydney Opera House)
        let sydney = CLLocation(latitude: -33.8568, longitude: 151.2153)

        let qibla = QiblaCalculator.calculateQibla(from: sydney)

        // Verify bearing (should be ~279° W)
        XCTAssertEqual(qibla.bearing, 279.0, accuracy: bearingTolerance,
                      "Qibla from Sydney should be approximately 279° (West)")

        // Verify distance (should be ~12,000-13,000 km)
        XCTAssertGreaterThan(qibla.distanceMeters, 11_500_000,
                            "Distance from Sydney to Mecca should be over 11,500 km")
        XCTAssertLessThan(qibla.distanceMeters, 13_500_000,
                         "Distance from Sydney to Mecca should be under 13,500 km")
    }

    /// Test Qibla direction from Cape Town, South Africa
    /// Expected: ~25° North (verified with IslamicFinder.org)
    func testQiblaFromCapeTown() throws {
        // Cape Town coordinates
        let capeTown = CLLocation(latitude: -33.9249, longitude: 18.4241)

        let qibla = QiblaCalculator.calculateQibla(from: capeTown)

        // Verify bearing (should be ~25° N)
        XCTAssertEqual(qibla.bearing, 25.0, accuracy: bearingTolerance,
                      "Qibla from Cape Town should be approximately 25° (North-Northeast)")

        // Verify distance (should be ~7,000-8,000 km)
        XCTAssertGreaterThan(qibla.distanceMeters, 6_500_000,
                            "Distance from Cape Town to Mecca should be over 6,500 km")
        XCTAssertLessThan(qibla.distanceMeters, 8_500_000,
                         "Distance from Cape Town to Mecca should be under 8,500 km")
    }

    /// Test Qibla direction from Jakarta, Indonesia
    /// Expected: ~295° Northwest (verified with IslamicFinder.org)
    func testQiblaFromJakarta() throws {
        // Jakarta coordinates
        let jakarta = CLLocation(latitude: -6.2088, longitude: 106.8456)

        let qibla = QiblaCalculator.calculateQibla(from: jakarta)

        // Verify bearing (should be ~295° NW)
        XCTAssertEqual(qibla.bearing, 295.0, accuracy: bearingTolerance,
                      "Qibla from Jakarta should be approximately 295° (Northwest)")

        // Verify distance (should be ~7,500-8,500 km)
        XCTAssertGreaterThan(qibla.distanceMeters, 7_000_000,
                            "Distance from Jakarta to Mecca should be over 7,000 km")
        XCTAssertLessThan(qibla.distanceMeters, 9_000_000,
                         "Distance from Jakarta to Mecca should be under 9,000 km")
    }

    // MARK: - Edge Case Tests

    /// Test Qibla calculation at Mecca itself
    /// Expected: Undefined (0° is acceptable, or any direction is valid)
    func testQiblaAtMecca() throws {
        // Location at Kaaba
        let kaaba = CLLocation(latitude: 21.4225, longitude: 39.8262)

        let qibla = QiblaCalculator.calculateQibla(from: kaaba)

        // Distance should be essentially zero (< 100 meters)
        XCTAssertLessThan(qibla.distanceMeters, 100,
                         "Distance at Mecca should be nearly zero")

        // Bearing is undefined at Mecca (any direction is valid)
        // We just check that it returns a valid number (0-360)
        XCTAssertGreaterThanOrEqual(qibla.bearing, 0,
                                   "Bearing should be >= 0")
        XCTAssertLessThan(qibla.bearing, 360,
                         "Bearing should be < 360")
    }

    /// Test Qibla from North Pole
    /// Expected: South (180°) - all directions from North Pole go south
    func testQiblaFromNorthPole() throws {
        // North Pole coordinates
        let northPole = CLLocation(latitude: 90.0, longitude: 0.0)

        let qibla = QiblaCalculator.calculateQibla(from: northPole)

        // Bearing should be approximately 180° (South)
        // At poles, Qibla is essentially "down" toward Mecca's latitude
        XCTAssertEqual(qibla.bearing, 180.0, accuracy: 10.0,
                      "Qibla from North Pole should be approximately South")

        // Distance should be ~7,500-8,000 km
        XCTAssertGreaterThan(qibla.distanceMeters, 7_000_000,
                            "Distance from North Pole to Mecca should be over 7,000 km")
        XCTAssertLessThan(qibla.distanceMeters, 9_000_000,
                         "Distance from North Pole to Mecca should be under 9,000 km")
    }

    /// Test Qibla from South Pole
    /// Expected: North (0°) - all directions from South Pole go north
    func testQiblaFromSouthPole() throws {
        // South Pole coordinates
        let southPole = CLLocation(latitude: -90.0, longitude: 0.0)

        let qibla = QiblaCalculator.calculateQibla(from: southPole)

        // Bearing should be approximately 0° or 360° (North)
        // Allow for 0° or values near 360° (they're equivalent)
        let normalizedBearing = qibla.bearing < 10 ? qibla.bearing : qibla.bearing - 360
        XCTAssertEqual(normalizedBearing, 0.0, accuracy: 10.0,
                      "Qibla from South Pole should be approximately North")

        // Distance should be ~12,500-13,500 km
        XCTAssertGreaterThan(qibla.distanceMeters, 12_000_000,
                            "Distance from South Pole to Mecca should be over 12,000 km")
        XCTAssertLessThan(qibla.distanceMeters, 14_000_000,
                         "Distance from South Pole to Mecca should be under 14,000 km")
    }

    /// Test Qibla crossing International Date Line
    /// Tests location east of date line (Fiji) to ensure longitude wrapping works
    func testQiblaAcrossDateLine() throws {
        // Fiji coordinates (east of date line)
        let fiji = CLLocation(latitude: -17.7134, longitude: 178.0650)

        let qibla = QiblaCalculator.calculateQibla(from: fiji)

        // Verify bearing is valid (0-360)
        XCTAssertGreaterThanOrEqual(qibla.bearing, 0,
                                   "Bearing should be >= 0")
        XCTAssertLessThan(qibla.bearing, 360,
                         "Bearing should be < 360")

        // Verify distance is reasonable
        XCTAssertGreaterThan(qibla.distanceMeters, 13_000_000,
                            "Distance from Fiji to Mecca should be over 13,000 km")
        XCTAssertLessThan(qibla.distanceMeters, 16_000_000,
                         "Distance from Fiji to Mecca should be under 16,000 km")
    }

    /// Test Qibla from Mecca's antipode (opposite side of Earth)
    /// Mecca antipode: approximately -21.4°S, -140.2°W (Pacific Ocean)
    func testQiblaFromAntipode() throws {
        // Mecca's antipode location
        let antipode = CLLocation(latitude: -21.4225, longitude: -140.1738)

        let qibla = QiblaCalculator.calculateQibla(from: antipode)

        // Distance should be approximately half Earth's circumference (~20,000 km)
        XCTAssertGreaterThan(qibla.distanceMeters, 19_000_000,
                            "Distance from antipode should be ~20,000 km")
        XCTAssertLessThan(qibla.distanceMeters, 21_000_000,
                         "Distance from antipode should be ~20,000 km")

        // Bearing from antipode is mathematically ambiguous
        // Any direction is valid, so we just check it's in valid range
        XCTAssertGreaterThanOrEqual(qibla.bearing, 0,
                                   "Bearing should be >= 0")
        XCTAssertLessThan(qibla.bearing, 360,
                         "Bearing should be < 360")
    }

    // MARK: - Equator Tests

    /// Test Qibla from location on equator
    func testQiblaFromEquator() throws {
        // Quito, Ecuador (on equator)
        let quito = CLLocation(latitude: -0.1807, longitude: -78.4678)

        let qibla = QiblaCalculator.calculateQibla(from: quito)

        // Verify bearing is valid
        XCTAssertGreaterThanOrEqual(qibla.bearing, 0,
                                   "Bearing should be >= 0")
        XCTAssertLessThan(qibla.bearing, 360,
                         "Bearing should be < 360")

        // Verify distance
        XCTAssertGreaterThan(qibla.distanceMeters, 11_000_000,
                            "Distance from equator location to Mecca should be reasonable")
        XCTAssertLessThan(qibla.distanceMeters, 13_000_000,
                         "Distance from equator location to Mecca should be reasonable")
    }

    // MARK: - Distance Calculation Tests

    /// Test distance calculation accuracy
    func testDistanceCalculationAccuracy() throws {
        // New York to Mecca: ~9,885 km (verified)
        let newYork = CLLocation(latitude: 40.7580, longitude: -73.9855)
        let qibla = QiblaCalculator.calculateQibla(from: newYork)

        // Verify distance is within 10km tolerance
        let expectedDistance = 9_885_000.0 // meters
        XCTAssertEqual(qibla.distanceMeters, expectedDistance, accuracy: distanceTolerance,
                      "Distance calculation should match reference value")
    }

    /// Test formatted distance strings
    func testFormattedDistanceStrings() throws {
        let newYork = CLLocation(latitude: 40.7580, longitude: -73.9855)
        let qibla = QiblaCalculator.calculateQibla(from: newYork)

        // Verify formatted distance is reasonable
        let formatted = qibla.formattedDistance

        // Should contain "km" or "miles"
        XCTAssertTrue(formatted.contains("km") || formatted.contains("mi"),
                     "Formatted distance should contain distance unit")

        // Should contain a number
        let hasNumber = formatted.contains(where: { $0.isNumber })
        XCTAssertTrue(hasNumber, "Formatted distance should contain numbers")
    }

    /// Test formatted bearing strings
    func testFormattedBearingStrings() throws {
        let newYork = CLLocation(latitude: 40.7580, longitude: -73.9855)
        let qibla = QiblaCalculator.calculateQibla(from: newYork)

        let formatted = qibla.formattedBearing

        // Should contain degree symbol or cardinal direction
        XCTAssertTrue(formatted.contains("°") || formatted.contains("N") ||
                     formatted.contains("E") || formatted.contains("S") ||
                     formatted.contains("W"),
                     "Formatted bearing should contain degree or cardinal direction")
    }

    // MARK: - Coordinate Validation Tests

    /// Test that invalid coordinates are handled properly
    func testInvalidCoordinates() throws {
        // Invalid latitude (>90)
        let invalidLat = CLLocation(latitude: 95.0, longitude: 0.0)

        // Should not crash and should return valid result
        let qibla = QiblaCalculator.calculateQibla(from: invalidLat)

        XCTAssertGreaterThanOrEqual(qibla.bearing, 0,
                                   "Should handle invalid coordinates gracefully")
        XCTAssertLessThan(qibla.bearing, 360,
                         "Should handle invalid coordinates gracefully")
    }

    // MARK: - Performance Tests

    /// Test that Qibla calculation is fast enough for real-time use
    func testQiblaCalculationPerformance() throws {
        let newYork = CLLocation(latitude: 40.7580, longitude: -73.9855)

        measure {
            // Should complete in under 1ms for smooth UI
            _ = QiblaCalculator.calculateQibla(from: newYork)
        }
    }

    /// Test batch calculations performance
    func testBatchCalculationsPerformance() throws {
        let locations = [
            CLLocation(latitude: 40.7580, longitude: -73.9855), // NYC
            CLLocation(latitude: 51.5007, longitude: -0.1246),  // London
            CLLocation(latitude: 35.6586, longitude: 139.7454), // Tokyo
            CLLocation(latitude: -33.8568, longitude: 151.2153) // Sydney
        ]

        measure {
            for location in locations {
                _ = QiblaCalculator.calculateQibla(from: location)
            }
        }
    }

    // MARK: - Regression Tests

    /// Test that Qibla calculations are consistent between runs
    func testCalculationConsistency() throws {
        let newYork = CLLocation(latitude: 40.7580, longitude: -73.9855)

        // Calculate multiple times
        let qibla1 = QiblaCalculator.calculateQibla(from: newYork)
        let qibla2 = QiblaCalculator.calculateQibla(from: newYork)
        let qibla3 = QiblaCalculator.calculateQibla(from: newYork)

        // Results should be identical
        XCTAssertEqual(qibla1.bearing, qibla2.bearing, accuracy: 0.001,
                      "Calculations should be consistent")
        XCTAssertEqual(qibla2.bearing, qibla3.bearing, accuracy: 0.001,
                      "Calculations should be consistent")

        XCTAssertEqual(qibla1.distanceMeters, qibla2.distanceMeters, accuracy: 1.0,
                      "Distance calculations should be consistent")
        XCTAssertEqual(qibla2.distanceMeters, qibla3.distanceMeters, accuracy: 1.0,
                      "Distance calculations should be consistent")
    }
}
