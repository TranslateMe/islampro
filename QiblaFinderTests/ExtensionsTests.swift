import XCTest
@testable import QiblaFinder
import Foundation

/// Comprehensive unit tests for Extensions.swift utility functions
/// Tests date formatting, cardinal directions, countdown strings, and Hijri calendar
///
/// Test Coverage:
/// - Cardinal direction string generation (bearingToCardinal)
/// - Date formatting functions (formattedTime, timeString)
/// - Countdown string generation (countdownString, timeRemaining)
/// - Hijri date conversion (hijriDateString)
/// - Edge cases and boundary conditions
///
/// Reference Data:
/// Cardinal directions follow standard 16-point compass rose
/// Hijri dates verified against Islamic calendar converters
final class ExtensionsTests: XCTestCase {

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    // MARK: - Cardinal Direction Tests

    /// Test cardinal direction for exact North (0°)
    func testCardinalDirectionNorth() throws {
        let direction = 0.0.bearingToCardinal()
        XCTAssertEqual(direction, "N", "0° should be North")
    }

    /// Test cardinal direction for exact East (90°)
    func testCardinalDirectionEast() throws {
        let direction = 90.0.bearingToCardinal()
        XCTAssertEqual(direction, "E", "90° should be East")
    }

    /// Test cardinal direction for exact South (180°)
    func testCardinalDirectionSouth() throws {
        let direction = 180.0.bearingToCardinal()
        XCTAssertEqual(direction, "S", "180° should be South")
    }

    /// Test cardinal direction for exact West (270°)
    func testCardinalDirectionWest() throws {
        let direction = 270.0.bearingToCardinal()
        XCTAssertEqual(direction, "W", "270° should be West")
    }

    /// Test Northeast (45°)
    func testCardinalDirectionNortheast() throws {
        let direction = 45.0.bearingToCardinal()
        XCTAssertEqual(direction, "NE", "45° should be Northeast")
    }

    /// Test Southeast (135°)
    func testCardinalDirectionSoutheast() throws {
        let direction = 135.0.bearingToCardinal()
        XCTAssertEqual(direction, "SE", "135° should be Southeast")
    }

    /// Test Southwest (225°)
    func testCardinalDirectionSouthwest() throws {
        let direction = 225.0.bearingToCardinal()
        XCTAssertEqual(direction, "SW", "225° should be Southwest")
    }

    /// Test Northwest (315°)
    func testCardinalDirectionNorthwest() throws {
        let direction = 315.0.bearingToCardinal()
        XCTAssertEqual(direction, "NW", "315° should be Northwest")
    }

    /// Test North-Northeast (22.5°)
    func testCardinalDirectionNNE() throws {
        let direction = 22.5.bearingToCardinal()
        XCTAssertEqual(direction, "NNE", "22.5° should be North-Northeast")
    }

    /// Test East-Northeast (67.5°)
    func testCardinalDirectionENE() throws {
        let direction = 67.5.bearingToCardinal()
        XCTAssertEqual(direction, "ENE", "67.5° should be East-Northeast")
    }

    /// Test boundary between N and NNE (11°)
    func testCardinalDirectionBoundaryNtoNNE() throws {
        let direction = 11.0.bearingToCardinal()
        // Should be either N or NNE depending on implementation
        XCTAssertTrue(direction == "N" || direction == "NNE",
                     "11° should be near N/NNE boundary")
    }

    /// Test wrap-around: 360° should equal 0° (North)
    func testCardinalDirection360Degrees() throws {
        let direction = 360.0.bearingToCardinal()
        XCTAssertEqual(direction, "N", "360° should wrap to North")
    }

    /// Test negative angle wrapping: -90° should equal 270° (West)
    func testCardinalDirectionNegativeAngle() throws {
        let direction = (-90.0).bearingToCardinal()
        XCTAssertEqual(direction, "W", "-90° should wrap to West (270°)")
    }

    /// Test very large angle: 450° should equal 90° (East)
    func testCardinalDirectionLargeAngle() throws {
        let direction = 450.0.bearingToCardinal()
        XCTAssertEqual(direction, "E", "450° should wrap to East (90°)")
    }

    /// Test all 16 cardinal directions
    func testAll16CardinalDirections() throws {
        let expectedDirections: [(bearing: Double, direction: String)] = [
            (0, "N"),
            (22.5, "NNE"),
            (45, "NE"),
            (67.5, "ENE"),
            (90, "E"),
            (112.5, "ESE"),
            (135, "SE"),
            (157.5, "SSE"),
            (180, "S"),
            (202.5, "SSW"),
            (225, "SW"),
            (247.5, "WSW"),
            (270, "W"),
            (292.5, "WNW"),
            (315, "NW"),
            (337.5, "NNW")
        ]

        for (bearing, expected) in expectedDirections {
            let result = bearing.bearingToCardinal()
            XCTAssertEqual(result, expected,
                          "\(bearing)° should be \(expected)")
        }
    }

    // MARK: - Date Formatting Tests

    /// Test formatted time for morning hour
    func testFormattedTimeMorning() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 7
        components.minute = 30
        components.timeZone = TimeZone.current

        guard let date = Calendar.current.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let formatted = date.formattedTime()

        // Should contain "7" or "07" and "30"
        XCTAssertTrue(formatted.contains("7") && formatted.contains("30"),
                     "Formatted time should contain hour and minute")

        // Should contain AM or am
        XCTAssertTrue(formatted.lowercased().contains("am"),
                     "Morning time should contain AM")
    }

    /// Test formatted time for afternoon hour
    func testFormattedTimeAfternoon() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 15 // 3 PM
        components.minute = 45
        components.timeZone = TimeZone.current

        guard let date = Calendar.current.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let formatted = date.formattedTime()

        // Should contain "3" or "03" and "45"
        XCTAssertTrue(formatted.contains("3") && formatted.contains("45"),
                     "Formatted time should contain hour and minute")

        // Should contain PM or pm
        XCTAssertTrue(formatted.lowercased().contains("pm"),
                     "Afternoon time should contain PM")
    }

    /// Test formatted time for midnight
    func testFormattedTimeMidnight() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 0
        components.minute = 0
        components.timeZone = TimeZone.current

        guard let date = Calendar.current.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let formatted = date.formattedTime()

        // Should show 12:00 AM
        XCTAssertTrue(formatted.contains("12") && formatted.contains("00"),
                     "Midnight should be formatted as 12:00")
        XCTAssertTrue(formatted.lowercased().contains("am"),
                     "Midnight should be AM")
    }

    /// Test formatted time for noon
    func testFormattedTimeNoon() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 12
        components.minute = 0
        components.timeZone = TimeZone.current

        guard let date = Calendar.current.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let formatted = date.formattedTime()

        // Should show 12:00 PM
        XCTAssertTrue(formatted.contains("12") && formatted.contains("00"),
                     "Noon should be formatted as 12:00")
        XCTAssertTrue(formatted.lowercased().contains("pm"),
                     "Noon should be PM")
    }

    // MARK: - Countdown String Tests

    /// Test countdown for future time (1 hour away)
    func testCountdownStringFuture1Hour() throws {
        let now = Date()
        let future = now.addingTimeInterval(3600) // +1 hour

        let countdown = future.countdownString(from: now)

        // Should contain "in" and "1" and "h"
        XCTAssertTrue(countdown.lowercased().contains("in"),
                     "Future countdown should contain 'in'")
        XCTAssertTrue(countdown.contains("1") && countdown.contains("h"),
                     "1 hour countdown should contain '1h'")
    }

    /// Test countdown for future time (30 minutes away)
    func testCountdownStringFuture30Minutes() throws {
        let now = Date()
        let future = now.addingTimeInterval(1800) // +30 minutes

        let countdown = future.countdownString(from: now)

        // Should contain "in" and "30" and "m"
        XCTAssertTrue(countdown.lowercased().contains("in"),
                     "Future countdown should contain 'in'")
        XCTAssertTrue(countdown.contains("30") && countdown.contains("m"),
                     "30 minute countdown should contain '30m'")
    }

    /// Test countdown for very near future (5 minutes away)
    func testCountdownStringFuture5Minutes() throws {
        let now = Date()
        let future = now.addingTimeInterval(300) // +5 minutes

        let countdown = future.countdownString(from: now)

        // Should contain "in" and "5" and "m"
        XCTAssertTrue(countdown.lowercased().contains("in"),
                     "Future countdown should contain 'in'")
        XCTAssertTrue(countdown.contains("5") && countdown.contains("m"),
                     "5 minute countdown should contain '5m'")
    }

    /// Test countdown for current time (happening now)
    func testCountdownStringNow() throws {
        let now = Date()
        let current = now.addingTimeInterval(30) // Within 1 minute

        let countdown = current.countdownString(from: now)

        // Should say "Now" or similar
        XCTAssertTrue(countdown.lowercased().contains("now") ||
                     countdown.lowercased().contains("in 0") ||
                     countdown.lowercased().contains("in 1"),
                     "Current time countdown should indicate 'now' or very soon")
    }

    /// Test countdown for past time
    func testCountdownStringPast() throws {
        let now = Date()
        let past = now.addingTimeInterval(-3600) // -1 hour

        let countdown = past.countdownString(from: now)

        // Should say "Passed" or similar
        XCTAssertTrue(countdown.lowercased().contains("passed") ||
                     countdown.lowercased().contains("ago") ||
                     countdown.lowercased().contains("past"),
                     "Past time countdown should indicate time has passed")
    }

    /// Test countdown for multiple hours (2 hours 30 minutes)
    func testCountdownStringMultipleHours() throws {
        let now = Date()
        let future = now.addingTimeInterval(9000) // +2.5 hours

        let countdown = future.countdownString(from: now)

        // Should contain hours and minutes
        XCTAssertTrue(countdown.contains("h") && countdown.contains("m"),
                     "Multi-hour countdown should show hours and minutes")
    }

    // MARK: - Hijri Date Tests

    /// Test Hijri date conversion for a known date
    /// January 1, 2025 = ~10 Rajab 1446
    func testHijriDateConversion2025() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        components.timeZone = TimeZone(identifier: "UTC")

        guard let date = Calendar.current.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let hijri = date.hijriDateString()

        // Should contain a Hijri month name (Arabic or English)
        XCTAssertFalse(hijri.isEmpty, "Hijri date should not be empty")

        // Should contain "1446" (the Hijri year)
        XCTAssertTrue(hijri.contains("1446"),
                     "Should contain Hijri year 1446")

        // Should contain a day number
        let hasNumber = hijri.contains(where: { $0.isNumber })
        XCTAssertTrue(hasNumber, "Hijri date should contain day number")
    }

    /// Test Hijri date for Ramadan 2025
    /// March 1, 2025 = ~1 Ramadan 1446
    func testHijriDateRamadan2025() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 3
        components.day = 1
        components.timeZone = TimeZone(identifier: "UTC")

        guard let date = Calendar.current.date(from: components) else {
            XCTFail("Failed to create date")
            return
        }

        let hijri = date.hijriDateString()

        // Should contain "Ramadan" (in English or Arabic رمضان)
        XCTAssertTrue(hijri.lowercased().contains("ramadan") ||
                     hijri.contains("رمضان"),
                     "Should contain Ramadan month name")

        // Should contain "1446"
        XCTAssertTrue(hijri.contains("1446"),
                     "Should contain Hijri year 1446")
    }

    /// Test that Hijri date is always non-empty for valid dates
    func testHijriDateNotEmpty() throws {
        let today = Date()
        let hijri = today.hijriDateString()

        XCTAssertFalse(hijri.isEmpty,
                      "Hijri date should not be empty for valid date")

        // Should be reasonable length (at least 10 characters)
        XCTAssertGreaterThan(hijri.count, 10,
                            "Hijri date should be reasonably formatted")
    }

    /// Test Hijri date for different months
    func testHijriDateDifferentMonths() throws {
        let dates = [
            (year: 2025, month: 1, day: 1),
            (year: 2025, month: 6, day: 15),
            (year: 2025, month: 12, day: 31)
        ]

        for (year, month, day) in dates {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            components.timeZone = TimeZone(identifier: "UTC")

            guard let date = Calendar.current.date(from: components) else {
                XCTFail("Failed to create date for \(year)-\(month)-\(day)")
                continue
            }

            let hijri = date.hijriDateString()

            XCTAssertFalse(hijri.isEmpty,
                          "Hijri date should be valid for \(year)-\(month)-\(day)")

            // Should contain a year
            let hasNumber = hijri.contains(where: { $0.isNumber })
            XCTAssertTrue(hasNumber,
                         "Hijri date should contain numbers for \(year)-\(month)-\(day)")
        }
    }

    // MARK: - Time Remaining Tests

    /// Test time remaining calculation (positive)
    func testTimeRemainingPositive() throws {
        let now = Date()
        let future = now.addingTimeInterval(3600) // +1 hour

        let remaining = future.timeRemaining(from: now)

        // Should be approximately 3600 seconds
        XCTAssertEqual(remaining, 3600, accuracy: 5,
                      "Time remaining should be ~3600 seconds")
    }

    /// Test time remaining calculation (negative - past)
    func testTimeRemainingNegative() throws {
        let now = Date()
        let past = now.addingTimeInterval(-1800) // -30 minutes

        let remaining = past.timeRemaining(from: now)

        // Should be approximately -1800 seconds
        XCTAssertEqual(remaining, -1800, accuracy: 5,
                      "Time remaining should be ~-1800 seconds for past time")
    }

    /// Test time remaining at exact moment
    func testTimeRemainingZero() throws {
        let now = Date()
        let same = now

        let remaining = same.timeRemaining(from: now)

        // Should be approximately 0
        XCTAssertEqual(remaining, 0, accuracy: 1,
                      "Time remaining should be ~0 for same time")
    }

    // MARK: - Edge Case Tests

    /// Test cardinal direction with decimal degrees
    func testCardinalDirectionDecimal() throws {
        let direction = 42.7.bearingToCardinal()

        // Should be NE (between N at 0 and E at 90)
        XCTAssertTrue(direction == "NE" || direction == "NNE",
                     "42.7° should be in Northeast quadrant")
    }

    /// Test countdown with very large time difference
    func testCountdownVeryLargeTimeSpan() throws {
        let now = Date()
        let farFuture = now.addingTimeInterval(86400 * 7) // +7 days

        let countdown = farFuture.countdownString(from: now)

        // Should contain days or hours
        XCTAssertTrue(countdown.contains("d") || countdown.contains("h"),
                     "Large time span should show days or hours")
    }

    /// Test formatted time consistency
    func testFormattedTimeConsistency() throws {
        let now = Date()

        // Format same time multiple times
        let format1 = now.formattedTime()
        let format2 = now.formattedTime()
        let format3 = now.formattedTime()

        XCTAssertEqual(format1, format2,
                      "Formatted time should be consistent")
        XCTAssertEqual(format2, format3,
                      "Formatted time should be consistent")
    }

    // MARK: - Performance Tests

    /// Test cardinal direction performance
    func testCardinalDirectionPerformance() throws {
        measure {
            for bearing in stride(from: 0.0, to: 360.0, by: 1.0) {
                _ = bearing.bearingToCardinal()
            }
        }
    }

    /// Test date formatting performance
    func testDateFormattingPerformance() throws {
        let dates = (0..<100).map { Date().addingTimeInterval(Double($0) * 3600) }

        measure {
            for date in dates {
                _ = date.formattedTime()
            }
        }
    }

    /// Test countdown string performance
    func testCountdownStringPerformance() throws {
        let now = Date()
        let dates = (0..<100).map { now.addingTimeInterval(Double($0) * 600) }

        measure {
            for date in dates {
                _ = date.countdownString(from: now)
            }
        }
    }

    /// Test Hijri conversion performance
    func testHijriConversionPerformance() throws {
        let dates = (0..<50).map { Date().addingTimeInterval(Double($0) * 86400) }

        measure {
            for date in dates {
                _ = date.hijriDateString()
            }
        }
    }

    // MARK: - Boundary Condition Tests

    /// Test cardinal direction at exact boundaries
    func testCardinalDirectionBoundaries() throws {
        let boundaries: [(bearing: Double, expected: String)] = [
            (0.0, "N"),
            (90.0, "E"),
            (180.0, "S"),
            (270.0, "W"),
            (359.9, "N") // Should wrap to North
        ]

        for (bearing, expected) in boundaries {
            let result = bearing.bearingToCardinal()
            XCTAssertEqual(result, expected,
                          "\(bearing)° should be \(expected)")
        }
    }

    /// Test countdown at minute boundaries
    func testCountdownMinuteBoundaries() throws {
        let now = Date()

        let testCases: [(seconds: TimeInterval, shouldContain: String)] = [
            (59, "1"), // Just under 1 minute
            (60, "1"), // Exactly 1 minute
            (61, "1"), // Just over 1 minute
            (3599, "59"), // Just under 1 hour
            (3600, "1"), // Exactly 1 hour
            (3601, "1") // Just over 1 hour
        ]

        for (seconds, shouldContain) in testCases {
            let future = now.addingTimeInterval(seconds)
            let countdown = future.countdownString(from: now)

            XCTAssertTrue(countdown.contains(shouldContain),
                         "Countdown for \(seconds)s should contain '\(shouldContain)'")
        }
    }
}
