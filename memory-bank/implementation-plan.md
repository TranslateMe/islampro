# Qibla Finder - Implementation Plan v3 (Maximized MVP)

## Pre-Development Setup
- ✓ Create Xcode project: "QiblaFinder", iOS 17+, SwiftUI, no Core Data
- ✓ Create folder structure (see tech-stack.md)
- Add Adhan Swift package via SPM
- ✓ Create memory-bank/ folder with all .md files

## Technical Notes
- **Swift Version:** 5.9 (Xcode 15.0.1)
- **Target iOS:** 17.0+
- **Architecture:** MVVM with Combine
- **Monetization:** $2.99 one-time premium unlock

---

## STEP 1: Project Foundation & Constants
**Task:**
- Create `Utilities/Constants.swift`
- Define Mecca coordinates: `MECCA_LAT = 21.4225`, `MECCA_LON = 39.8262`
- Define color constants using iOS system colors
- Define strings for permission messages
- Define app-wide constants (alignment threshold = 5°, update frequency = 60Hz)

**Files to create:**
- `Utilities/Constants.swift`

**Test:**
- Build project successfully
- No compiler errors
- Constants accessible from other files
- Print constants to console to verify values

---

## STEP 1b: Extensions & Helpers
**Task:**
- Create `Utilities/Extensions.swift`
- **String extensions:** Localization helpers, Arabic text handling
- **Date extensions:** Formatted time strings ("5:42 AM"), countdown strings ("in 2h 15m"), Hijri conversion wrapper
- **Double extensions:** Bearing formatting with cardinal directions, distance formatting with commas ("6,240 km")
- **Color extensions:** Custom theme colors, hex color initializer

**Files to create:**
- `Utilities/Extensions.swift`

**Example implementations:**
```swift
// Double extension for bearing
extension Double {
    var cardinalDirection: String {
        // 0-22.5 = N, 22.5-67.5 = NE, etc.
    }
    var formattedBearing: String {
        // "285° NW"
    }
}

// Date extension for countdown
extension Date {
    func countdownString(to target: Date) -> String {
        // "in 2h 15m" or "Now"
    }
}
```

**Test:**
- Create test cases for each extension
- Verify bearing 45° returns "NE"
- Verify date countdown calculations accurate
- Verify distance formatting includes commas

---

## STEP 2: Location Manager - Modern Permission Request
**Task:**
- Create `Services/LocationManager.swift` as ObservableObject
- Import CoreLocation and CoreLocationUI
- Request "When In Use" location permission using modern CoreLocationUI button
- Publish permission status (@Published var authorizationStatus)
- Handle permission states: notDetermined, denied, authorized
- Implement delegate methods for status changes

**Files to create:**
- `Services/LocationManager.swift`

**Implementation notes:**
- Use `CLLocationManager` for actual location tracking
- Use `LocationButton` from CoreLocationUI for permission UI
- LocationButton provides better UX and builds user trust

**Test:**
- Run app, verify modern location button appears
- Tap button, verify location permission alert appears
- Grant permission, verify status changes to authorized
- Print authorization status to console

---

## STEP 3: Location Manager - Get Coordinates
**Task:**
- In LocationManager, implement CLLocationManagerDelegate
- Start location updates when authorized
- Publish current coordinates (@Published var currentLocation: CLLocation?)
- Implement one-time location fetch (requestLocation)
- Cache last known location in UserDefaults (latitude, longitude, timestamp)
- Retrieve cached location on app launch

**Files to modify:**
- `Services/LocationManager.swift`

**Caching strategy:**
```swift
// Save: UserDefaults.standard.set(location.coordinate.latitude, forKey: "cached_lat")
// Load: Check cache on init, use if < 24 hours old
```

**Test:**
- Run app, after permission granted
- Print coordinates to console: latitude, longitude
- Verify coordinates update when device moves
- Close and reopen app, verify cached location loads
- Verify timestamp of cached location

---

## STEP 4: Qibla Calculator - Bearing Calculation
**Task:**
- Create `Services/QiblaCalculator.swift`
- Implement function: `calculateQiblaBearing(from userLocation: CLLocation) -> Double`
- Use Great Circle formula (Haversine) to calculate bearing to Mecca
- Return bearing in degrees (0-360)
- Also calculate distance to Mecca in meters
- Handle edge cases (at Mecca = 0°, antipode, poles)

**Formula reference:**
```swift
// Great Circle bearing formula
// Δlong = MECCA_LON - userLon
// θ = atan2(sin(Δlong) * cos(MECCA_LAT),
//           cos(userLat) * sin(MECCA_LAT) - sin(userLat) * cos(MECCA_LAT) * cos(Δlong))
// Convert from radians to degrees, normalize to 0-360
```

**Files to create:**
- `Services/QiblaCalculator.swift`

**Test:**
- Given test coordinates:
  - New York (40.7128°N, 74.0060°W) → Expected: ~58° (Northeast)
  - London (51.5074°N, 0.1278°W) → Expected: ~119° (Southeast)
  - Sydney (-33.8688°S, 151.2093°E) → Expected: ~277° (West)
  - Tokyo (35.6762°N, 139.6503°E) → Expected: ~293° (Northwest)
- Verify calculations match IslamicFinder.org or Qibla Compass online tools
- Verify distance calculations accurate

---

## STEP 5: Qibla Direction Model
**Task:**
- Create `Models/QiblaDirection.swift`
- Define struct with: bearing (Double), distanceKm (Double), accuracy (enum: accurate/calibrating/interference)
- Add computed property for cardinal direction string using Double extension
- Make struct Equatable and Codable for testing

**Files to create:**
- `Models/QiblaDirection.swift`

**Example:**
```swift
struct QiblaDirection: Equatable, Codable {
    let bearing: Double
    let distanceKm: Double
    let accuracy: AccuracyLevel

    enum AccuracyLevel {
        case accurate, calibrating, interference
    }

    var cardinalDirection: String {
        bearing.cardinalDirection
    }

    var formattedBearing: String {
        bearing.formattedBearing
    }
}
```

**Test:**
- Create test QiblaDirection instance
- Verify bearing 45° returns "NE"
- Verify bearing 270° returns "W"
- Verify bearing 135° returns "SE"

---

## STEP 6: Compass Manager - Magnetometer Setup
**Task:**
- Create `Services/CompassManager.swift` as ObservableObject
- Import CoreMotion and CoreLocation
- Initialize CMMotionManager for device motion
- Initialize CLLocationManager for heading updates (uses magnetometer + GPS)
- Request magnetometer/heading updates (60Hz target)
- Publish current device heading (@Published var heading: Double)
- Convert magnetic heading to true heading (adjust for magnetic declination)
- Handle compass unavailable state (simulator, old device)

**Files to create:**
- `Services/CompassManager.swift`

**Implementation choice:**
Use CLLocationManager.heading (preferred) as it auto-adjusts for magnetic declination. Fallback to CMMotionManager if needed.

**Test:**
- Run on PHYSICAL iPhone (simulator won't have compass)
- Print device heading to console every second
- Rotate device, verify heading updates smoothly (0-360°)
- Face north, verify heading ≈ 0° (±5° tolerance)
- Face east, verify heading ≈ 90°

---

## STEP 7: Compass Manager - Calibration Handling
**Task:**
- In CompassManager, detect compass accuracy from CLHeading
- Publish calibration status (@Published var needsCalibration: Bool)
- Publish accuracy level (@Published var accuracy: CLLocationAccuracy)
- Detect magnetic interference (accuracy drops below threshold)
- Optionally show system calibration prompt when accuracy low

**Files to modify:**
- `Services/CompassManager.swift`

**Accuracy thresholds:**
```swift
// CLLocationAccuracy.high = accurate (green)
// CLLocationAccuracy.medium = calibrating (yellow)
// CLLocationAccuracy.low = interference (red)
```

**Test:**
- Run app near magnetic interference (laptop, metal desk, speakers)
- Verify needsCalibration flag becomes true
- Verify accuracy level changes
- Move away from interference, verify flag becomes false
- Wave device in figure-8 pattern, verify calibration improves

---

## STEP 8: Compass ViewModel - Business Logic
**Task:**
- Create `ViewModels/CompassViewModel.swift` as ObservableObject
- Inject LocationManager, CompassManager, QiblaCalculator (dependency injection)
- Use Combine to observe location and heading changes
- Calculate Qibla bearing when location updates
- Combine sensor data to compute Qibla pointer angle
- Formula: `pointerAngle = qiblaBearing - deviceHeading`
- Publish QiblaDirection model (@Published var qiblaDirection: QiblaDirection?)
- Handle permission denied state
- Handle no location state
- Handle compass unavailable state

**Files to create:**
- `ViewModels/CompassViewModel.swift`

**Combine pipeline:**
```swift
Publishers.CombineLatest(locationManager.$currentLocation, compassManager.$heading)
    .compactMap { location, heading in
        // Calculate qibla direction
    }
    .assign(to: &$qiblaDirection)
```

**Test:**
- Print pointerAngle to console
- Rotate device, verify pointerAngle changes correctly
- When device points to Qibla, pointerAngle should ≈ 0° (±5°)
- Verify location updates trigger recalculation
- Test with denied permissions, verify state handled

---

## STEP 9a: Compass Ring View - Basic Circle
**Task:**
- Create `Views/Compass/CompassRingView.swift`
- Draw circular ring using SwiftUI Circle with stroke
- Diameter: 300pt (responsive on smaller screens)
- Stroke: 2pt, system gray color
- Position in center of screen using GeometryReader

**Files to create:**
- `Views/Compass/CompassRingView.swift`

**Test:**
- Display CompassRingView in ContentView preview
- Verify perfect circle appears
- Test in light/dark mode, verify stroke color adapts
- Test on iPhone SE (small screen) and iPhone Pro Max (large screen)

---

## STEP 9b: Compass Ring View - Cardinal Markers
**Task:**
- In CompassRingView, add N/S/E/W text labels
- Position at 0°, 90°, 180°, 270° around circle perimeter
- Use SF Pro Display font, 16pt, semibold
- Labels should NOT rotate with device (stay upright)
- Add subtle degree markers every 30° (small dashes)

**Files to modify:**
- `Views/Compass/CompassRingView.swift`

**Implementation:**
```swift
// Use ZStack with rotationEffect for positioning
// But counter-rotate text to keep upright
Text("N")
    .rotationEffect(.degrees(0))
    .offset(y: -150)
    .rotationEffect(.degrees(-heading)) // Counter-rotate
```

**Test:**
- Verify N at top, E at right, S at bottom, W at left
- Rotate device, verify labels stay upright (don't rotate)
- Test readability in light/dark mode
- Verify degree markers visible but subtle

---

## STEP 9c: Qibla Pointer View - Kaaba Icon
**Task:**
- Create `Views/Compass/QiblaPointerView.swift`
- Display Kaaba icon (use SF Symbol "building.2.fill" initially, custom later)
- Size: 50x50pt for icon, with background circle 60x60pt
- Icon color: Gold (#FFD700)
- Background: Semi-transparent white/black circle
- Add subtle shadow for depth
- Position at center, pointing upward initially

**Files to create:**
- `Views/Compass/QiblaPointerView.swift`

**Design:**
```swift
ZStack {
    Circle()
        .fill(Color.white.opacity(0.2))
        .frame(width: 60, height: 60)
    Image(systemName: "building.2.fill")
        .resizable()
        .frame(width: 50, height: 50)
        .foregroundColor(Color(hex: "#FFD700"))
}
.shadow(radius: 5)
```

**Test:**
- Display QiblaPointerView in CompassRingView
- Verify icon appears centered
- Verify gold color visible in light/dark mode
- Verify shadow adds depth

---

## STEP 9d: Qibla Pointer View - Rotation Animation
**Task:**
- In QiblaPointerView, accept pointerAngle binding
- Apply rotation: `.rotationEffect(Angle(degrees: pointerAngle))`
- Add smooth animation: `.animation(.easeOut(duration: 0.2), value: pointerAngle)`
- Pointer should rotate as device rotates
- Optimize for 60fps (no dropped frames)

**Files to modify:**
- `Views/Compass/QiblaPointerView.swift`

**Animation tuning:**
- Use .easeOut for natural deceleration
- Keep duration short (0.2s) for responsiveness
- Consider using .interpolatingSpring for even smoother motion

**Test:**
- Connect to CompassViewModel's pointerAngle
- Rotate device 360°, verify pointer rotates smoothly
- Use Xcode Instruments to verify 60fps (no lag or jitter)
- Verify animation feels natural, not robotic

---

## STEP 9e: Compass View - Degree Indicator
**Task:**
- Create `Views/Compass/CompassView.swift`
- At top center, display current Qibla bearing
- Format: "285° NW" using Double extension
- Font: SF Pro Display, 32pt bold for degrees, 20pt for cardinal
- Update in real-time as device rotates
- Add subtle background blur for readability

**Files to create:**
- `Views/Compass/CompassView.swift`

**Design:**
```swift
VStack {
    HStack(alignment: .firstTextBaseline, spacing: 4) {
        Text("\(Int(bearing))°")
            .font(.system(size: 32, weight: .bold, design: .rounded))
        Text(cardinalDirection)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.secondary)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
    .background(.ultraThinMaterial)
    .cornerRadius(20)
}
```

**Test:**
- Display bearing text above compass
- Rotate device, verify degrees update smoothly
- Verify cardinal direction correct (285° = NW, 45° = NE, etc.)
- Test readability over compass (background blur effective)

---

## STEP 9f: Compass View - Distance to Mecca
**Task:**
- In CompassView, display distance to Mecca in km
- Position below compass ring
- Format: "6,240 km to Mecca" using Double extension
- Use CLLocation.distance(from:) to calculate
- Font: SF Pro Text, 17pt, regular weight
- Update when location changes (not every frame)

**Files to modify:**
- `Views/Compass/CompassView.swift`

**Implementation:**
```swift
let meccaLocation = CLLocation(latitude: MECCA_LAT, longitude: MECCA_LON)
let distanceMeters = userLocation.distance(from: meccaLocation)
let distanceKm = distanceMeters / 1000
// Format with comma separator: "6,240 km"
```

**Test:**
- Verify distance shown in km with comma formatting
- Test from different locations:
  - New York: ~11,000 km
  - London: ~4,600 km
  - Sydney: ~12,200 km
- Verify updates when location changes significantly

---

## STEP 9g: Accuracy Indicator View
**Task:**
- Create `Views/Compass/AccuracyIndicatorView.swift`
- Small circle indicator in top-right corner
- Size: 12pt diameter
- Color based on compass accuracy:
  - Green (#34C759) = accurate
  - Yellow (#FFCC00) = calibrating
  - Red (#FF3B30) = interference
- Add tooltip on tap explaining status
- Subtle pulsing animation when not accurate

**Files to create:**
- `Views/Compass/AccuracyIndicatorView.swift`

**Design:**
```swift
Circle()
    .fill(indicatorColor)
    .frame(width: 12, height: 12)
    .overlay(
        Circle()
            .stroke(Color.white.opacity(0.5), lineWidth: 2)
    )
    .scaleEffect(needsCalibration ? 1.2 : 1.0)
    .animation(.easeInOut(duration: 0.8).repeatForever(), value: needsCalibration)
```

**Test:**
- Display in CompassView corner
- Verify green when compass accurate
- Create interference (place near metal), verify turns yellow/red
- Verify pulsing animation when calibrating
- Tap indicator, verify tooltip appears

---

## STEP 9h: Compass View - Assembly
**Task:**
- In CompassView, combine all subviews in proper layer order:
  - Background gradient (bottom layer)
  - CompassRingView with cardinal markers
  - QiblaPointerView (rotating, middle layer)
  - Degree indicator (top center)
  - Distance text (bottom center)
  - AccuracyIndicatorView (top-right corner)
- Wire up CompassViewModel using @StateObject
- Add gradient background (white→light blue in light mode, black→deep blue in dark)
- Handle loading state (show spinner while getting location)
- Handle error states

**Files to modify:**
- `Views/Compass/CompassView.swift`

**Layout structure:**
```swift
ZStack {
    // Background gradient
    LinearGradient(...)

    VStack {
        // Degree indicator
        DegreeIndicatorView()

        Spacer()

        // Compass ring + pointer
        ZStack {
            CompassRingView()
            QiblaPointerView(angle: viewModel.pointerAngle)
        }

        Spacer()

        // Distance text
        DistanceView()
    }

    // Accuracy indicator (overlay)
    VStack {
        HStack {
            Spacer()
            AccuracyIndicatorView()
        }
        Spacer()
    }
}
```

**Test:**
- Full compass screen displays correctly on device
- All elements visible and properly layered (no overlaps)
- Rotation smooth at 60fps, no visual glitches
- Test in light/dark mode, verify gradient appropriate
- Test loading state, verify spinner appears
- Test error states (no location, denied permission)

---

## STEP 10: Haptic Feedback Throughout App
**Task:**
- Create `Utilities/HapticManager.swift`
- Implement multiple feedback types:
  - **Alignment pulse:** When device points within ±5° of Qibla (medium impact)
  - **Tab selection:** When switching tabs (light impact)
  - **Button taps:** For all buttons (selection feedback)
  - **Success:** When actions complete (notification success)
  - **Error:** When errors occur (notification error)
- Use UIImpactFeedbackGenerator, UISelectionFeedbackGenerator, UINotificationFeedbackGenerator
- Only trigger alignment pulse once when entering range (debounce)
- Cache generators for performance

**Files to create:**
- `Utilities/HapticManager.swift`

**Example API:**
```swift
class HapticManager {
    static let shared = HapticManager()

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle)
    func selection()
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
    func qiblaAlignment() // Special case with debounce
}
```

**Test:**
- Rotate device toward Qibla, feel haptic pulse at alignment
- Continue rotating, should not pulse again until re-aligned
- Switch tabs, feel light haptic
- Tap buttons, feel selection feedback
- Test on device (haptics don't work in simulator)

---

## STEP 11: Prayer Times Calculator Setup
**Task:**
- Add Adhan Swift package via Swift Package Manager
- URL: https://github.com/batoulapps/adhan-swift
- Create `Services/PrayerTimeCalculator.swift`
- Import Adhan library
- Initialize with user coordinates (CLLocationCoordinate2D)
- Set default calculation method (Muslim World League initially)
- Calculate today's 5 prayer times: Fajr, Dhuhr, Asr, Maghrib, Isha
- Also calculate tomorrow's Fajr (for overnight countdown)
- Handle calculation errors gracefully

**Files to create:**
- `Services/PrayerTimeCalculator.swift`

**Implementation:**
```swift
import Adhan

class PrayerTimeCalculator {
    func calculatePrayerTimes(for coordinates: CLLocationCoordinate2D,
                             method: CalculationMethod = .muslimWorldLeague) -> PrayerTimes? {
        let params = CalculationMethod.muslimWorldLeague.params
        let date = Date()
        return PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params)
    }
}
```

**Test:**
- Given test coordinates (e.g., Dubai: 25.2048°N, 55.2708°E)
- Print prayer times to console
- Verify times match IslamicFinder.org for that location and date
- Test multiple cities across time zones
- Test edge cases (high latitude, date line)

---

## STEP 12: Prayer Model
**Task:**
- Create `Models/Prayer.swift`
- Define struct: name (String), arabicName (String), time (Date), isNext (Bool)
- Add computed property for formatted time string ("5:42 AM") using Date extension
- Add computed property for countdown string ("in 2h 15m") using Date extension
- Make struct Identifiable, Equatable for SwiftUI List
- Add prayer type enum (Fajr, Dhuhr, Asr, Maghrib, Isha)

**Files to create:**
- `Models/Prayer.swift`

**Example:**
```swift
struct Prayer: Identifiable, Equatable {
    let id = UUID()
    let type: PrayerType
    let time: Date
    var isNext: Bool

    enum PrayerType: String, CaseIterable {
        case fajr, dhuhr, asr, maghrib, isha

        var arabicName: String {
            switch self {
            case .fajr: return "الفجر"
            case .dhuhr: return "الظهر"
            case .asr: return "العصر"
            case .maghrib: return "المغرب"
            case .isha: return "العشاء"
            }
        }
    }

    var formattedTime: String {
        time.formatted(date: .omitted, time: .shortened)
    }

    var countdown: String {
        time.countdownString(to: Date())
    }
}
```

**Test:**
- Create test Prayer instance
- Verify time formatting correct ("5:42 AM" format)
- Verify countdown calculation accurate ("in 2h 15m", "Now", "Passed")
- Test in different locales (English, Arabic)

---

## STEP 13: Prayer Times ViewModel
**Task:**
- Create `ViewModels/PrayerTimesViewModel.swift` as ObservableObject
- Inject LocationManager, PrayerTimeCalculator
- Observe location changes with Combine
- Calculate prayer times when location updates
- Publish array of Prayer models (@Published var prayers: [Prayer])
- Determine next upcoming prayer (set isNext = true)
- Update countdown every second using Timer.publish
- Recalculate at midnight (new day)
- Cache prayer times for offline use

**Files to create:**
- `ViewModels/PrayerTimesViewModel.swift`

**Implementation:**
```swift
class PrayerTimesViewModel: ObservableObject {
    @Published var prayers: [Prayer] = []

    private var timer: AnyCancellable?

    func startCountdownTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateNextPrayer()
                self?.checkMidnight()
            }
    }

    func updateNextPrayer() {
        // Determine which prayer is next
        // Update isNext flag
    }
}
```

**Test:**
- Print prayers array to console
- Verify all 5 prayers present with correct times
- Verify next prayer correctly identified (isNext = true)
- Wait 1 minute, verify countdown decrements
- Test near midnight, verify recalculation occurs
- Test offline (cached times still available)

---

## STEP 14: Prayer Row View
**Task:**
- Create `Views/PrayerTimes/PrayerRowView.swift`
- Display prayer in HStack layout:
  - Left: Prayer name (English + Arabic in VStack)
  - Center: Spacer
  - Right: Time + countdown in VStack
- Highlight if isNext:
  - Green background (system green with opacity)
  - Bold text
  - Slightly larger
- Font: SF Pro Text, 17pt body, SF Arabic for Arabic text
- Add subtle divider between rows
- Support RTL layout for Arabic

**Files to create:**
- `Views/PrayerTimes/PrayerRowView.swift`

**Design:**
```swift
HStack(spacing: 16) {
    // Prayer name
    VStack(alignment: .leading, spacing: 4) {
        Text(prayer.type.rawValue.capitalized)
            .font(.headline)
            .fontWeight(prayer.isNext ? .bold : .regular)
        Text(prayer.type.arabicName)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }

    Spacer()

    // Time + countdown
    VStack(alignment: .trailing, spacing: 4) {
        Text(prayer.formattedTime)
            .font(.headline)
            .fontWeight(prayer.isNext ? .bold : .regular)
        Text(prayer.countdown)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
.padding()
.background(prayer.isNext ? Color.green.opacity(0.15) : Color.clear)
.cornerRadius(12)
```

**Test:**
- Display test Prayer in preview
- Verify layout correct (name left, time right)
- Test next prayer highlight (green background, bold)
- Test non-next prayer (normal appearance)
- Test in RTL mode (Arabic), verify layout flips

---

## STEP 15: Prayer Times View Assembly
**Task:**
- Create `Views/PrayerTimes/PrayerTimesView.swift`
- Display List of PrayerRowView for each prayer
- Header section with:
  - Location name (city from CLPlacemark)
  - Current Hijri date
  - Current Gregorian date
- Wire up PrayerTimesViewModel using @StateObject
- Auto-refresh every second (countdown updates)
- Handle loading state
- Handle no location state
- Pull to refresh gesture

**Files to create:**
- `Views/PrayerTimes/PrayerTimesView.swift`

**Layout:**
```swift
NavigationView {
    List {
        Section {
            // Header: Location + dates
            VStack(alignment: .leading, spacing: 8) {
                Text(locationName)
                    .font(.title2)
                    .bold()
                Text(hijriDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(gregorianDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }

        Section("Today's Prayer Times") {
            ForEach(viewModel.prayers) { prayer in
                PrayerRowView(prayer: prayer)
            }
        }
    }
    .navigationTitle("Prayer Times")
    .refreshable {
        await viewModel.refresh()
    }
}
```

**Test:**
- Display prayer times list
- Verify all 5 prayers shown in order
- Verify next prayer highlighted
- Wait 1 minute, verify countdown updates
- Pull to refresh, verify times recalculate
- Test in different locations, verify times change

---

## STEP 15a: Hijri Date Service
**Task:**
- Create `Services/HijriDateService.swift`
- Use Foundation's `Calendar(identifier: .islamicUmAlQura)` for Hijri conversion
- Convert Gregorian Date to Hijri date
- Format Hijri date string: "15 Ramadan 1446"
- Support both English and Arabic month names
- Handle date component extraction (day, month, year)

**Files to create:**
- `Services/HijriDateService.swift`

**Implementation:**
```swift
class HijriDateService {
    private let hijriCalendar = Calendar(identifier: .islamicUmAlQura)

    func hijriDateString(from date: Date, locale: Locale = .current) -> String {
        let components = hijriCalendar.dateComponents([.day, .month, .year], from: date)
        let day = components.day ?? 1
        let month = hijriMonthName(components.month ?? 1, locale: locale)
        let year = components.year ?? 1446
        return "\(day) \(month) \(year)"
    }

    private func hijriMonthName(_ month: Int, locale: Locale) -> String {
        // Return Arabic or English month name
        let monthNames = [
            "Muharram", "Safar", "Rabi' al-awwal", "Rabi' al-thani",
            "Jumada al-awwal", "Jumada al-thani", "Rajab", "Sha'ban",
            "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"
        ]
        return monthNames[month - 1]
    }
}
```

**Test:**
- Convert current date to Hijri
- Verify format: "15 Ramadan 1446"
- Compare with online Hijri calendar (islamicfinder.org)
- Test edge cases (month boundaries, year transitions)
- Test in English and Arabic locales

---

## STEP 16: Main Content View - 4 Tab Navigation
**Task:**
- Modify `ContentView.swift`
- Add TabView with 4 tabs:
  - **Tab 1:** CompassView (icon: "location.north.fill", label: "Qibla")
  - **Tab 2:** PrayerTimesView (icon: "clock.fill", label: "Prayer Times")
  - **Tab 3:** MapView (icon: "map.fill", label: "Map")
  - **Tab 4:** SettingsView (icon: "gearshape.fill", label: "Settings")
- Default to Tab 1 (Compass)
- Add haptic feedback on tab selection
- Persist selected tab (optional)

**Files to modify:**
- `ContentView.swift`

**Implementation:**
```swift
TabView(selection: $selectedTab) {
    CompassView()
        .tabItem {
            Label("Qibla", systemImage: "location.north.fill")
        }
        .tag(0)

    PrayerTimesView()
        .tabItem {
            Label("Prayer Times", systemImage: "clock.fill")
        }
        .tag(1)

    MapView()
        .tabItem {
            Label("Map", systemImage: "map.fill")
        }
        .tag(2)

    SettingsView()
        .tabItem {
            Label("Settings", systemImage: "gearshape.fill")
        }
        .tag(3)
}
.onChange(of: selectedTab) { _ in
    HapticManager.shared.selection()
}
```

**Test:**
- Launch app, verify opens to Qibla tab
- Tap each tab, verify switches correctly
- Verify tab icons display correctly
- Feel haptic feedback on tab switch
- Test in light/dark mode

---

## STEP 16a: MapKit Tab - Map View
**Task:**
- Create `Views/Map/MapView.swift`
- Import MapKit
- Display map centered between user location and Mecca
- Add annotation for user location (blue dot)
- Add annotation for Mecca (custom Kaaba icon)
- Draw line between user and Mecca (great circle path)
- Add distance label overlay
- Support zoom controls
- Handle location permission states

**Files to create:**
- `Views/Map/MapView.swift`

**Implementation:**
```swift
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var region = MKCoordinateRegion(...)

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: viewModel.locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                if location.isMecca {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.gold)
                } else {
                    Circle()
                        .fill(.blue)
                        .frame(width: 15, height: 15)
                }
            }
        }
        .overlay(alignment: .bottom) {
            // Distance label
            Text("\(viewModel.distanceKm) km to Mecca")
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
        }
    }
}
```

**Test:**
- Open Map tab, verify map appears
- Verify user location marked (blue dot)
- Verify Mecca marked (Kaaba icon)
- Verify line drawn between locations
- Verify distance label accurate
- Test zoom in/out
- Test in different locations worldwide

---

## STEP 16b: Settings Tab - Calculation Methods & Themes
**Task:**
- Create `Views/Settings/SettingsView.swift`
- Create `Services/SettingsManager.swift` for UserDefaults persistence
- **Calculation Methods section:**
  - List of methods (Muslim World League, ISNA, Umm al-Qura, etc.)
  - Use Adhan library's CalculationMethod enum
  - Save selection to UserDefaults
- **Theme section (Premium):**
  - Accent color picker
  - Theme presets (Default, Ocean, Forest, Sunset)
- **About section:**
  - App version
  - Privacy policy link
  - Rate app button
  - Contact developer
- **Premium section:**
  - Show purchase button if not purchased
  - Show "Premium Active" badge if purchased

**Files to create:**
- `Views/Settings/SettingsView.swift`
- `Services/SettingsManager.swift`

**Design:**
```swift
NavigationView {
    List {
        Section("Prayer Calculations") {
            Picker("Method", selection: $selectedMethod) {
                ForEach(CalculationMethod.allCases) { method in
                    Text(method.displayName)
                }
            }
        }

        Section("Theme") {
            if isPremium {
                ColorPicker("Accent Color", selection: $accentColor)
                // Theme presets
            } else {
                HStack {
                    Text("Custom Themes")
                    Spacer()
                    Text("Premium")
                        .foregroundColor(.secondary)
                }
            }
        }

        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            Button("Rate QiblaFinder") {
                // Open App Store
            }
        }

        if !isPremium {
            Section {
                Button("Unlock Premium - $2.99") {
                    // Open paywall
                }
            }
        }
    }
    .navigationTitle("Settings")
}
```

**Test:**
- Open Settings tab
- Select different calculation methods, verify saves
- Verify prayer times update with new method
- Test theme picker (if premium)
- Tap rate app, verify opens App Store
- Test premium button appears if not purchased

---

## STEP 16c: Onboarding View - First Launch
**Task:**
- Create `Views/Onboarding/OnboardingView.swift`
- Show only on first app launch (check UserDefaults flag)
- 3-page onboarding:
  - **Page 1:** Welcome + app purpose
  - **Page 2:** Location permission explanation
  - **Page 3:** How to use compass
- Use TabView with PageTabViewStyle for swipe navigation
- "Get Started" button on final page
- Sets "hasSeenOnboarding" flag in UserDefaults
- Use modern LocationButton from CoreLocationUI on page 2

**Files to create:**
- `Views/Onboarding/OnboardingView.swift`

**Design:**
```swift
TabView {
    // Page 1
    VStack(spacing: 20) {
        Image(systemName: "building.2.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.gold)
        Text("Welcome to QiblaFinder")
            .font(.largeTitle)
            .bold()
        Text("Find the Qibla direction anywhere in the world")
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
    }

    // Page 2
    VStack(spacing: 20) {
        Image(systemName: "location.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.blue)
        Text("Location Access")
            .font(.largeTitle)
            .bold()
        Text("We need your location to calculate the Qibla direction accurately")
            .multilineTextAlignment(.center)
        LocationButton(.shareCurrentLocation) {
            // Request location
        }
    }

    // Page 3
    VStack(spacing: 20) {
        Image(systemName: "location.north.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.green)
        Text("How to Use")
            .font(.largeTitle)
            .bold()
        Text("Rotate your device until the Kaaba icon points up. You'll feel a vibration when aligned.")
            .multilineTextAlignment(.center)
        Button("Get Started") {
            // Dismiss onboarding
        }
        .buttonStyle(.borderedProminent)
    }
}
.tabViewStyle(.page)
.indexViewStyle(.page(backgroundDisplayMode: .always))
```

**Test:**
- Delete app and reinstall, verify onboarding appears
- Swipe through all pages
- Tap "Get Started", verify onboarding dismissed
- Close and reopen app, verify onboarding doesn't show again
- Test location button on page 2

---

## STEP 17: Permission View - Location Denied
**Task:**
- Create `Views/Shared/PermissionView.swift`
- Show when location permission denied or restricted
- Display clear explanation with icon
- Message: "Location permission required for Qibla direction"
- Add button: "Open Settings" → opens iOS Settings app using UIApplication.openSettingsURLString
- Use clean, respectful design (not pushy)
- Show as overlay in CompassView when needed

**Files to create:**
- `Views/Shared/PermissionView.swift`

**Design:**
```swift
VStack(spacing: 24) {
    Image(systemName: "location.slash.fill")
        .resizable()
        .frame(width: 80, height: 80)
        .foregroundColor(.red)

    Text("Location Access Required")
        .font(.title2)
        .bold()

    Text("QiblaFinder needs your location to determine the accurate Qibla direction. Please enable location access in Settings.")
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal)

    Button("Open Settings") {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    .buttonStyle(.borderedProminent)
}
.padding()
```

**Test:**
- Deny location permission in Settings
- Launch app, verify PermissionView appears
- Tap "Open Settings", verify iOS Settings app opens
- Grant permission in Settings, return to app
- Verify compass appears (PermissionView dismissed)

---

## STEP 18: Error View - No GPS Signal
**Task:**
- Create `Views/Shared/ErrorView.swift`
- Show when GPS unavailable but permission granted
- Display cached location with note: "Using last known location"
- Show accuracy warning if cache old (> 24 hours)
- Add retry button to request fresh location
- Handle case where no cache exists (first launch)

**Files to create:**
- `Views/Shared/ErrorView.swift`

**Design:**
```swift
VStack(spacing: 20) {
    Image(systemName: "antenna.radiowaves.left.and.right.slash")
        .resizable()
        .frame(width: 60, height: 60)
        .foregroundColor(.orange)

    Text("GPS Signal Weak")
        .font(.headline)

    if let cachedLocation = viewModel.cachedLocation {
        Text("Using last known location from \(cachedLocation.timestamp.formatted())")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    } else {
        Text("No location available. Please ensure Location Services are enabled.")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }

    Button("Retry") {
        viewModel.requestLocation()
    }
    .buttonStyle(.bordered)
}
.padding()
```

**Test:**
- Turn off device Location Services completely
- Launch app, verify ErrorView appears
- Verify shows cached location if available
- Tap retry button
- Turn Location Services back on, verify compass restores
- Test with no cached location (fresh install + no location)

---

## STEP 19: Dark Mode & Color System
**Task:**
- In `Assets.xcassets`, create custom color sets:
  - **BackgroundPrimary:** White (light), Black (dark)
  - **BackgroundSecondary:** Light gray (light), Dark gray (dark)
  - **AccentGold:** #FFD700 (both modes)
  - **TextPrimary:** Black (light), White (dark)
  - **TextSecondary:** Gray (both modes)
- Apply colors consistently across all views
- Use `.background(Color("BackgroundPrimary"))` instead of hardcoded colors
- Verify all text readable in both modes
- Test compass visibility in dark mode (sufficient contrast)
- Test prayer times readability

**Files to modify:**
- `Assets.xcassets` (add color sets)
- All View files (replace hardcoded colors)

**Color set creation:**
1. Right-click Assets.xcassets > New Color Set
2. Set Light Appearance value
3. Set Dark Appearance value
4. Use in code: `Color("BackgroundPrimary")`

**Test:**
- Toggle iOS dark mode (Settings > Display & Brightness)
- Verify app adapts instantly (no restart needed)
- Check all screens readable:
  - Compass view (gradient, text, icons)
  - Prayer times (rows, headers)
  - Map view (overlays)
  - Settings (list, text)
- Verify gold Kaaba icon visible in both modes
- Verify compass ring visible in both modes

---

## STEP 20: App Icon & Launch Screen
**Task:**
- Design app icon concept:
  - Kaaba silhouette OR compass needle
  - Green background (brand color)
  - Simple, recognizable at small sizes
  - Works in light/dark mode
- Create icon using design tool (Figma, Sketch) or hire designer
- Export all sizes: 1024x1024 for App Store + device sizes
- Add to `Assets.xcassets/AppIcon.appiconset`
- **Launch screen:** Use modern Info.plist approach (iOS 17+)
  - Set background color in Info.plist
  - Show app icon during launch (system default)
  - No custom storyboard needed

**Files to modify:**
- `Assets.xcassets/AppIcon.appiconset`
- `Info.plist` (launch screen settings)

**Info.plist launch screen config:**
```xml
<key>UILaunchScreen</key>
<dict>
    <key>UIColorName</key>
    <string>BackgroundPrimary</string>
    <key>UIImageName</key>
    <string>AppIcon</string>
</dict>
```

**Test:**
- Delete app from device, reinstall
- Verify icon appears on home screen
- Verify icon looks good at small size
- Launch app, verify launch screen shows briefly (< 1 second)
- Verify launch screen adapts to light/dark mode
- Test icon in Spotlight search
- Test icon in Settings app list

---

## STEP 21: Localization - Full Arabic Support with RTL
**Task:**
- Add Arabic language to project (Xcode > Project > Localizations > Add Arabic)
- Create `en.lproj/Localizable.strings` for English
- Create `ar.lproj/Localizable.strings` for Arabic
- Translate ALL user-facing strings:
  - Prayer names (already in Adhan library)
  - UI labels, buttons
  - Permission messages
  - Error messages
  - Settings options
  - Onboarding text
- Use `NSLocalizedString` in code for all strings
- **Implement full RTL layout:**
  - Use SwiftUI's `.environment(\.layoutDirection, ...)`
  - Test HStack, VStack, List layouts flip correctly
  - Verify compass stays centered (not affected by RTL)
  - Verify text alignment (leading/trailing, not left/right)
- Prayer names from Adhan should come in Arabic automatically

**Files to create:**
- `Resources/en.lproj/Localizable.strings`
- `Resources/ar.lproj/Localizable.strings`

**Example Localizable.strings (English):**
```
"compass.title" = "Qibla Compass";
"compass.distance" = "km to Mecca";
"prayers.title" = "Prayer Times";
"settings.title" = "Settings";
"permission.message" = "Location permission required for Qibla direction";
"onboarding.welcome" = "Welcome to QiblaFinder";
```

**Example Localizable.strings (Arabic):**
```
"compass.title" = "بوصلة القبلة";
"compass.distance" = "كم إلى مكة";
"prayers.title" = "أوقات الصلاة";
"settings.title" = "الإعدادات";
"permission.message" = "مطلوب إذن الموقع لتحديد اتجاه القبلة";
"onboarding.welcome" = "مرحبا بك في محدد القبلة";
```

**RTL Implementation:**
```swift
// In views, use .leading/.trailing instead of .left/.right
HStack {
    Text("Prayer Name")
    Spacer()
    Text("Time")
}
.frame(maxWidth: .infinity, alignment: .leading) // Auto-flips in RTL

// Compass stays centered (not affected)
ZStack {
    CompassRingView()
    QiblaPointerView()
}
.frame(maxWidth: .infinity, maxHeight: .infinity) // Centered in all layouts
```

**Test:**
- Change iOS language to Arabic (Settings > General > Language & Region)
- Launch app, verify ALL text displays in Arabic
- Verify right-to-left layout throughout:
  - Tab bar (icons flip)
  - Lists (disclosure indicators on left)
  - Navigation (back button on right)
  - Prayer times rows (layout flipped)
- Verify compass remains centered (not affected by RTL)
- Change back to English, verify layout flips back
- Test in both light/dark modes with Arabic

---

## STEP 22: Performance Optimization
**Task:**
- Profile app using Xcode Instruments
- **Time Profiler:** Ensure compass runs at 60fps constantly
  - Check for main thread blocking
  - Optimize sensor data processing
- **Allocations:** Check memory usage < 50MB typical
  - Look for memory leaks
  - Ensure proper ARC usage
- **Energy Log:** Verify low battery impact
  - Minimize background activity
  - Optimize sensor polling frequency
- **Launch Time:** Verify cold start < 800ms
  - Minimize work in app initialization
  - Defer non-critical loading
- Reduce unnecessary SwiftUI view updates
  - Use `@Published` judiciously
  - Consider `equatable()` for complex views
- Optimize compass animation performance
  - Use `drawingGroup()` if needed
  - Consider Metal rendering for complex graphics

**Tools:**
- Xcode > Product > Profile > Time Profiler
- Xcode > Product > Profile > Allocations
- Xcode > Product > Profile > Energy Log

**Test:**
- Run Time Profiler while rotating device
  - Verify no CPU spikes > 50%
  - Verify 60fps maintained
- Run Allocations during typical session
  - Verify memory stable (no constant growth)
  - Verify < 50MB typical usage
- Run Energy Log during 5-minute session
  - Verify "Very Low" or "Low" energy impact
  - Verify no background activity when app inactive
- Measure launch time:
  - Clean install, cold start 10 times
  - Average < 800ms from tap to compass visible
- Test on older device (iPhone 12 or older)
  - Verify smooth performance

---

## STEP 23: Unit Tests - Calculations
**Task:**
- Create unit test target if not exists
- Create `QiblaFinderTests/QiblaCalculatorTests.swift`
  - Test bearing calculations for known locations
  - Test distance calculations
  - Test edge cases:
    - At Mecca (bearing should be 0° or undefined)
    - At antipode (180° from Mecca)
    - At North/South poles
    - Crossing international date line
- Create `QiblaFinderTests/PrayerTimeCalculatorTests.swift`
  - Test prayer time calculations for known cities/dates
  - Compare with reference data from IslamicFinder
  - Test different calculation methods
  - Test edge cases (high latitudes, date boundaries)
- Create `QiblaFinderTests/ExtensionsTests.swift`
  - Test cardinal direction calculations
  - Test date formatting
  - Test countdown string generation
  - Test Hijri date conversion

**Files to create:**
- `QiblaFinderTests/QiblaCalculatorTests.swift`
- `QiblaFinderTests/PrayerTimeCalculatorTests.swift`
- `QiblaFinderTests/ExtensionsTests.swift`

**Example test:**
```swift
func testQiblaBearingFromNewYork() {
    let nyLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
    let bearing = QiblaCalculator.calculateQiblaBearing(from: nyLocation)
    XCTAssertEqual(bearing, 58.0, accuracy: 1.0, "NYC to Mecca should be ~58° NE")
}

func testPrayerTimesInDubai() {
    let coords = CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708)
    let date = Date(/* specific test date */)
    let times = PrayerTimeCalculator.calculatePrayerTimes(for: coords, date: date)
    // Assert times match reference
}
```

**Test:**
- Run tests (Cmd+U in Xcode)
- Verify all tests pass
- Run test coverage report
  - Xcode > Product > Scheme > Edit Scheme > Test > Options > Code Coverage
  - Target > 80% coverage for Services/ and Utilities/
- Fix any failing tests
- Add more test cases for edge scenarios

---

## STEP 24: Device Testing - Real iPhone
**Task:**
- Install app on physical iPhone (compass requires hardware)
- **Compass accuracy testing:**
  - Test in multiple orientations (portrait, landscape, upside down)
  - Test indoors and outdoors
  - Test near magnetic interference (speakers, metal)
  - Compare with online Qibla finder tools
  - Verify ±5° accuracy tolerance acceptable
- **Location testing:**
  - Test in multiple physical locations (if possible)
  - Test with WiFi only (no cellular)
  - Test in airplane mode (uses cached location)
  - Test location updates while moving
- **Network testing:**
  - Test with internet connection (should work)
  - Test without internet (should work offline)
  - Verify all features work offline
- **Performance testing:**
  - Verify smooth 60fps animations
  - Monitor battery drain during 5-minute session (< 1%)
  - Check device doesn't heat up
  - Verify no lag or stutter
- **Stress testing:**
  - Rapidly switch between tabs
  - Rotate device quickly
  - Background/foreground app multiple times
  - Test low battery mode

**Test locations (if possible):**
- Current location (home/office)
- Different building/neighborhood
- Indoor vs outdoor
- Near metal structures

**Test:**
- Compass points accurately to Mecca (±5° tolerance)
  - Cross-reference with online tools
  - Test from known location
- No lag or stutter during rotation (60fps)
- Works offline perfectly (all features)
- Battery drain < 1% per 5-minute session
- Prayer times accurate (compare with IslamicFinder)
- Haptic feedback works (feels natural)
- App remains stable (no crashes)
- All UI elements visible and readable
- Dark mode switches properly

---

## STEP 25: Premium Features - StoreKit Setup
**Task:**
- Create in-app purchase product in App Store Connect:
  - Product ID: `com.qiblafinder.premium`
  - Type: Non-consumable (one-time purchase)
  - Price: $2.99 USD (adjust per region)
- Create `Services/StoreManager.swift` using StoreKit 2
- Implement purchase flow:
  - Fetch product info
  - Handle purchase
  - Verify receipt
  - Store premium status in UserDefaults + Keychain
  - Restore purchases
- Create `Views/Settings/PaywallView.swift`
- List premium features clearly
- Simple, respectful purchase flow (not pushy)
- Handle purchase states: purchasing, success, failure, cancelled

**Files to create:**
- `Services/StoreManager.swift`
- `Views/Settings/PaywallView.swift`

**Implementation:**
```swift
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPremium: Bool = false

    private let productID = "com.qiblafinder.premium"

    init() {
        Task {
            await loadProducts()
            await checkPurchaseStatus()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [productID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            // Handle successful purchase
            isPremium = true
            // Store in UserDefaults + Keychain
        case .userCancelled:
            // User cancelled
            break
        case .pending:
            // Purchase pending
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async {
        // Check for existing purchases
    }
}
```

**Paywall design:**
```swift
VStack(spacing: 24) {
    Text("Unlock Premium")
        .font(.largeTitle)
        .bold()

    VStack(alignment: .leading, spacing: 16) {
        FeatureRow(icon: "bell.fill", title: "Prayer Notifications", description: "Never miss a prayer")
        FeatureRow(icon: "widget.small", title: "Home Screen Widget", description: "See next prayer at a glance")
        FeatureRow(icon: "paintpalette.fill", title: "Custom Themes", description: "Personalize your experience")
        FeatureRow(icon: "gear", title: "Advanced Settings", description: "Multiple calculation methods")
        FeatureRow(icon: "applewatch", title: "Apple Watch App", description: "Qibla on your wrist")
    }

    if let product = storeManager.products.first {
        Button("Purchase - \(product.displayPrice)") {
            Task {
                try? await storeManager.purchase(product)
            }
        }
        .buttonStyle(.borderedProminent)
    }

    Button("Restore Purchases") {
        Task {
            await storeManager.restorePurchases()
        }
    }
    .font(.caption)
}
```

**Test:**
- Configure sandbox test user in App Store Connect
- Sign in with test account on device
- Verify product loads (displays $2.99)
- Tap purchase, complete sandbox purchase
- Verify premium unlocks (all features available)
- Close and reopen app, verify premium persists
- Tap restore purchases, verify works
- Test on fresh install (should restore from receipt)

---

## STEP 25a: Premium - Prayer Notifications
**Task:**
- Import UserNotifications framework
- Create `Services/NotificationManager.swift`
- Request notification permission (only for premium users)
- Schedule local notifications for each prayer time
- Notifications triggered 5 minutes before prayer (customizable in settings)
- Include prayer name and time in notification
- Use custom sound if available
- Update notifications daily (recalculate prayer times)
- Handle timezone changes
- Add settings toggle to enable/disable per-prayer notifications

**Files to create:**
- `Services/NotificationManager.swift`

**Implementation:**
```swift
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    func requestPermission() async -> Bool {
        let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }

    func schedulePrayerNotifications(prayers: [Prayer]) {
        // Cancel existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for prayer in prayers {
            let content = UNMutableNotificationContent()
            content.title = "\(prayer.type.rawValue.capitalized) Prayer"
            content.body = "Prayer time in 5 minutes at \(prayer.formattedTime)"
            content.sound = .default

            // Schedule 5 minutes before
            let triggerDate = prayer.time.addingTimeInterval(-5 * 60)
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(identifier: prayer.id.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}
```

**Settings integration:**
Add to SettingsView:
```swift
Section("Notifications") {
    if isPremium {
        Toggle("Prayer Notifications", isOn: $notificationsEnabled)
        if notificationsEnabled {
            Stepper("Notify \(minutesBefore) minutes before", value: $minutesBefore, in: 0...30)
        }
    } else {
        HStack {
            Text("Prayer Notifications")
            Spacer()
            Text("Premium")
                .foregroundColor(.secondary)
        }
    }
}
```

**Test:**
- Purchase premium (or use sandbox)
- Enable notifications in settings
- Grant notification permission when prompted
- Verify notifications scheduled (check device notification settings)
- Wait for notification time (or change device time)
- Verify notification appears with correct content
- Test different prayer times
- Test notification sounds
- Disable notifications, verify they stop

---

## STEP 25b: Premium - Home Screen Widget
**Task:**
- Add Widget Extension to project (File > New > Target > Widget Extension)
- Name: "QiblaWidget"
- Create widget showing next prayer time
- Widget sizes:
  - Small: Next prayer name + countdown
  - Medium: Next prayer + all prayer times
  - Large: Compass + prayer times (optional)
- Use WidgetKit timeline to update every minute
- Share data with main app using App Groups
- Store prayer times in UserDefaults (shared suite)
- Handle timezone changes
- Widget tapping opens main app

**Files to create:**
- `QiblaWidget/QiblaWidget.swift`
- `QiblaWidget/QiblaWidgetView.swift`

**Setup:**
1. Add App Group: `group.com.qiblafinder.app`
2. Enable App Groups in both main app and widget targets
3. Store prayer times in shared UserDefaults:
```swift
let sharedDefaults = UserDefaults(suiteName: "group.com.qiblafinder.app")
```

**Widget implementation:**
```swift
import WidgetKit
import SwiftUI

struct QiblaWidget: Widget {
    let kind: String = "QiblaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QiblaWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Prayer")
        .description("Shows the next upcoming prayer time")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct QiblaWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.nextPrayer.type.rawValue.capitalized)
                .font(.headline)
            Text(entry.nextPrayer.formattedTime)
                .font(.title)
                .bold()
            Text(entry.nextPrayer.countdown)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
```

**Test:**
- Build widget target
- Long-press home screen, tap + to add widget
- Verify "QiblaFinder" appears in widget gallery
- Add small widget, verify shows next prayer
- Add medium widget, verify shows all prayers
- Wait 1 minute, verify countdown updates
- Tap widget, verify opens main app
- Test on device (widgets don't work well in simulator)
- Test across timezone changes
- Test premium gate (widget only works if premium)

---

## STEP 25c: Premium - Multiple Calculation Methods
**Task:**
- In SettingsView, add calculation method picker (already created in Step 16b)
- Integrate with PrayerTimeCalculator
- Support Adhan library's calculation methods:
  - Muslim World League (default)
  - ISNA (Islamic Society of North America)
  - Umm al-Qura (Makkah)
  - Egyptian General Authority of Survey
  - University of Islamic Sciences, Karachi
  - Dubai
  - Kuwait
  - Qatar
  - Singapore
  - Tehran
  - Custom (allow manual adjustment)
- Update prayer times when method changes
- Show method description in settings
- Gate this feature behind premium

**Files to modify:**
- `Services/PrayerTimeCalculator.swift`
- `Views/Settings/SettingsView.swift`

**Implementation in PrayerTimeCalculator:**
```swift
import Adhan

extension CalculationMethod {
    var displayName: String {
        switch self {
        case .muslimWorldLeague: return "Muslim World League"
        case .egyptian: return "Egyptian Authority"
        case .karachi: return "University of Karachi"
        case .ummAlQura: return "Umm al-Qura (Makkah)"
        case .dubai: return "Dubai"
        case .qatar: return "Qatar"
        case .kuwait: return "Kuwait"
        case .singapore: return "Singapore"
        case .northAmerica: return "ISNA (North America)"
        case .other: return "Custom"
        @unknown default: return "Unknown"
        }
    }

    var description: String {
        switch self {
        case .muslimWorldLeague: return "Used in Europe, Americas, parts of Asia"
        case .northAmerica: return "Used in USA, Canada"
        case .ummAlQura: return "Used in Saudi Arabia"
        // ... add descriptions
        default: return ""
        }
    }
}

func calculatePrayerTimes(for coordinates: CLLocationCoordinate2D,
                         method: CalculationMethod) -> PrayerTimes? {
    let params = method.params
    let date = Date()
    return PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params)
}
```

**Settings UI:**
```swift
Section("Prayer Calculation Method") {
    if isPremium {
        Picker("Method", selection: $selectedMethod) {
            ForEach(CalculationMethod.allCases, id: \.self) { method in
                VStack(alignment: .leading) {
                    Text(method.displayName)
                    Text(method.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .tag(method)
            }
        }
        .pickerStyle(.navigationLink)
    } else {
        HStack {
            VStack(alignment: .leading) {
                Text("Calculation Method")
                Text("Muslim World League")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("Premium")
                .foregroundColor(.secondary)
        }
        .onTapGesture {
            // Show paywall
        }
    }
}
```

**Test:**
- Purchase premium
- Open Settings > Calculation Method
- Select different method (e.g., ISNA)
- Return to Prayer Times tab
- Verify times changed (compare with IslamicFinder using same method)
- Test multiple methods, verify accuracy
- Test in different locations (methods produce different results)
- Without premium, verify picker shows "Premium" label

---

## STEP 25d: Premium - Custom Themes & Accent Colors
**Task:**
- Create theme system with predefined themes:
  - **Default:** Green accent
  - **Ocean:** Blue gradient
  - **Forest:** Green gradient
  - **Sunset:** Orange/pink gradient
  - **Custom:** User picks accent color
- Store theme preference in UserDefaults
- Apply theme throughout app:
  - Tab bar accent
  - Buttons
  - Highlights
  - Gradients
- Add ColorPicker for custom accent
- Gate behind premium

**Files to create:**
- `Models/Theme.swift`
- `Services/ThemeManager.swift`

**Implementation:**
```swift
enum Theme: String, CaseIterable, Codable {
    case `default`, ocean, forest, sunset, custom

    var displayName: String {
        rawValue.capitalized
    }

    var accentColor: Color {
        switch self {
        case .default: return .green
        case .ocean: return .blue
        case .forest: return Color(red: 0.2, green: 0.6, blue: 0.3)
        case .sunset: return .orange
        case .custom: return Color("CustomAccent") // User-defined
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .default: return [.white, Color(red: 0.9, green: 1.0, blue: 0.9)]
        case .ocean: return [.white, Color(red: 0.9, green: 0.95, blue: 1.0)]
        case .forest: return [.white, Color(red: 0.95, green: 1.0, blue: 0.95)]
        case .sunset: return [.white, Color(red: 1.0, green: 0.95, blue: 0.9)]
        case .custom: return [.white, .gray.opacity(0.1)]
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }

    @Published var customAccentColor: Color {
        didSet {
            // Store color components in UserDefaults
        }
    }

    init() {
        // Load from UserDefaults
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "default"
        currentTheme = Theme(rawValue: savedTheme) ?? .default
        // Load custom color
        customAccentColor = .green
    }
}
```

**Settings UI:**
```swift
Section("Theme") {
    if isPremium {
        Picker("Theme", selection: $themeManager.currentTheme) {
            ForEach(Theme.allCases, id: \.self) { theme in
                HStack {
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 20, height: 20)
                    Text(theme.displayName)
                }
                .tag(theme)
            }
        }

        if themeManager.currentTheme == .custom {
            ColorPicker("Accent Color", selection: $themeManager.customAccentColor)
        }
    } else {
        HStack {
            Text("Custom Themes")
            Spacer()
            Text("Premium")
                .foregroundColor(.secondary)
        }
        .onTapGesture {
            // Show paywall
        }
    }
}
```

**Apply theme in views:**
```swift
// In App or root view
@StateObject var themeManager = ThemeManager()

ContentView()
    .environmentObject(themeManager)
    .accentColor(themeManager.currentTheme.accentColor)

// In CompassView
@EnvironmentObject var themeManager: ThemeManager

var body: some View {
    ZStack {
        LinearGradient(colors: themeManager.currentTheme.gradientColors, startPoint: .top, endPoint: .bottom)
        // ... rest of compass
    }
}
```

**Test:**
- Purchase premium
- Open Settings > Theme
- Select each theme, verify colors change throughout app
- Select Custom, pick a color
- Verify accent color updates:
  - Tab bar selection
  - Buttons
  - Compass gradient
  - Prayer time highlights
- Close and reopen app, verify theme persists
- Test in light/dark mode with each theme

---

## STEP 25e: Premium - Apple Watch App (Optional)
**Task:**
- Add watchOS target to project (File > New > Target > Watch App)
- Create companion Apple Watch app with:
  - **Complication:** Shows next prayer time
  - **Watch face:** Qibla direction (uses device orientation)
  - **List:** Prayer times for today
- Use WatchConnectivity to sync data from iPhone
- Handle watch-only usage (if possible)
- Optimize for small screen
- Use SwiftUI for watchOS

**Files to create:**
- `QiblaFinderWatch/ContentView.swift`
- `QiblaFinderWatch/CompassView.swift`
- `QiblaFinderWatch/PrayerTimesView.swift`
- `Shared/WatchConnectivityManager.swift`

**Watch app structure:**
```swift
// WatchOS ContentView
TabView {
    CompassView()
        .tabItem {
            Image(systemName: "location.north.fill")
        }

    PrayerTimesView()
        .tabItem {
            Image(systemName: "clock.fill")
        }
}
```

**Complications:**
```swift
// Support multiple complication families
// Show next prayer name + countdown
// Update every minute
```

**WatchConnectivity:**
```swift
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    func sendPrayerTimes(_ prayers: [Prayer]) {
        guard WCSession.default.isReachable else { return }
        let data = try? JSONEncoder().encode(prayers)
        WCSession.default.sendMessageData(data ?? Data(), replyHandler: nil)
    }
}
```

**Test:**
- Pair Apple Watch with iPhone
- Build and run watch app
- Verify compass shows on watch
- Verify prayer times sync from iPhone
- Add complication to watch face
- Verify complication shows next prayer
- Test haptic feedback on watch
- Test offline functionality
- Test battery impact on watch
- Consider if watch app is feasible for MVP (time constraint)

**Note:** Apple Watch app is optional for MVP. Implement if time allows, otherwise move to post-launch.

---

## STEP 26: Final Polish - Animations & UX
**Task:**
- Add subtle entrance animations to all views:
  - Compass: Fade + scale animation on appear
  - Prayer times: Staggered fade-in for rows
  - Map: Zoom animation on appear
  - Settings: Fade-in
- Add smooth transitions between tabs
- Add animation to prayer row highlight change (when next prayer updates)
- Polish haptic feedback timing (ensure feels natural, not excessive)
- Add loading indicators for location acquisition
- Add skeleton loading states for prayer times
- Add error animations (shake for errors)
- Polish button interactions (scale on press)
- Add swipe gestures where appropriate
- Ensure all interactions feel responsive (< 100ms feedback)

**Files to modify:**
- All View files (add animation modifiers)

**Example animations:**
```swift
// Compass entrance
CompassView()
    .scaleEffect(isAppearing ? 1.0 : 0.8)
    .opacity(isAppearing ? 1.0 : 0.0)
    .onAppear {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isAppearing = true
        }
    }

// Prayer rows stagger
ForEach(Array(prayers.enumerated()), id: \.element.id) { index, prayer in
    PrayerRowView(prayer: prayer)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .opacity
        ))
        .animation(.easeOut(duration: 0.3).delay(Double(index) * 0.1), value: prayers)
}

// Button press
Button("Purchase Premium") {
    // Action
}
.scaleEffect(isPressed ? 0.95 : 1.0)
.animation(.easeInOut(duration: 0.1), value: isPressed)

// Error shake
.modifier(ShakeEffect(shakes: errorOccurred ? 2 : 0))

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat {
        get { CGFloat(shakes) }
        set { shakes = Int(newValue) }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 10 * sin(animatableData * .pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
```

**Loading states:**
```swift
if viewModel.isLoading {
    VStack {
        ProgressView()
        Text("Finding Qibla direction...")
            .font(.caption)
            .foregroundColor(.secondary)
    }
} else {
    CompassView()
}

// Skeleton loading
if viewModel.prayers.isEmpty {
    ForEach(0..<5) { _ in
        SkeletonRow()
    }
    .redacted(reason: .placeholder)
}
```

**Test:**
- Launch app, verify compass animates in smoothly
- Switch tabs, verify smooth transition with fade
- Wait for next prayer time change, verify highlight animates
- Test loading states (turn off location, verify spinner)
- Press buttons, verify scale feedback
- Trigger error, verify shake animation
- Test overall feel:
  - All animations smooth (60fps)
  - Haptic feedback natural (not annoying)
  - Interactions responsive
  - Loading states clear
- Test on device (animations better than simulator)
- Get user feedback on polish

---

## STEP 27: Build & Submit to App Store
**Task:**
- Set version to 1.0 (build 1) in project settings
- Verify all entitlements configured:
  - Location (When In Use)
  - App Groups (for widget)
  - In-App Purchase
- Create App Store icon (1024x1024)
- Archive app in Xcode (Product > Archive)
- Validate archive (check for errors/warnings)
- Upload to App Store Connect
- Fill out App Store listing:
  - **Name:** QiblaFinder
  - **Subtitle:** Fast & Accurate Qibla Compass
  - **Description:** Full description with features
  - **Keywords:** qibla, compass, prayer, times, islamic, muslim, mecca, kaaba
  - **Screenshots:** 6.7" and 5.5" display sizes (required)
  - **Privacy Policy:** Create and host privacy policy
  - **Support URL:** Create support page or email
- Configure in-app purchase in App Store Connect
- Submit for review
- Respond to any review feedback

**App Store description template:**
```
QiblaFinder - The Beautiful Qibla Compass

Find the exact direction to Mecca from anywhere in the world with our elegant, ad-free compass.

FEATURES:
• Accurate Qibla Compass - Uses GPS and magnetometer for precise direction
• Prayer Times - Accurate times for all 5 daily prayers
• Interactive Map - Visualize your location relative to Mecca
• Offline Mode - Works perfectly without internet
• Beautiful Design - Clean, minimal interface with dark mode
• Privacy First - No data collection, no tracking

PREMIUM ($2.99 one-time):
• Prayer Notifications - Never miss a prayer
• Home Screen Widget - See next prayer at a glance
• Apple Watch App - Qibla on your wrist
• Multiple Calculation Methods - Choose your preferred method
• Custom Themes - Personalize your experience

Perfect for Muslims who pray 5 times daily and need a reliable, fast, and beautiful Qibla finder.

No ads. No subscriptions. No tracking.
```

**Screenshots needed:**
- 6.7" (iPhone Pro Max): 1290 x 2796
- 5.5" (iPhone Plus): 1242 x 2208
Capture:
1. Compass view (main feature)
2. Prayer times view
3. Map view
4. Premium features showcase
5. Dark mode example

**Test:**
- Archive builds successfully, no errors
- Upload succeeds
- Validate app in App Store Connect (no issues)
- Test with TestFlight (invite beta testers)
- Create App Store screenshots with annotations
- Verify all metadata complete
- Submit for review
- Monitor review status
- Respond to any questions from App Review

---

---

# ✅ STEPS 1-27 COMPLETED (v1.0 MVP SHIPPED)

**Completion Date:** October 16, 2025
**Status:** v1.0 Ready for App Store Submission
**Build Status:** ✅ Zero Errors, All Tests Passing

All MVP implementation steps (Steps 1-27) have been successfully completed. The app is production-ready with:
- ✅ Core Qibla compass system (60fps, GPS+magnetometer fusion)
- ✅ Prayer times calculator with 5 daily prayers
- ✅ Interactive map view
- ✅ Full settings system with 4 themes
- ✅ Complete onboarding flow
- ✅ Dark mode support
- ✅ Arabic localization (149+ strings, RTL support)
- ✅ Performance optimized (75% CPU reduction, <50MB memory)
- ✅ 85+ unit tests with edge case coverage
- ✅ 32 professional animations with haptic feedback

See `memory-bank/v1.0-COMPLETION-SUMMARY.md` for detailed completion documentation.

---

# POST-LAUNCH IMPLEMENTATION PLANS (v1.1 - v1.4)

## Version 1.1 - Competitive Parity (2-3 weeks post-launch)

**Timeline:** 2-3 weeks | **Effort:** 11-15 hours | **Release Target:** Week 4-5 after v1.0 launch

**Goal:** Match core features of competing Qibla apps while maintaining superior UX

### STEP 28 (v1.1.1): Adhan Audio Playback

**Status:** Planned | **Priority:** High | **Effort:** 4-6 hours

**Task:**
- Add audio playback capability for Adhan (call to prayer)
- Support 3-5 different reciter voices
- Play audio at exact prayer time (triggered by local notification)
- Background audio support (plays even when app closed)
- Volume control in settings
- Download reciters on-demand (not bundled, to save app size)
- Fallback to default bell sound if audio unavailable

**Files to create:**
- `Services/AdhanAudioManager.swift`
- `Models/Reciter.swift`
- `Views/Settings/AdhanSettingsView.swift`

**Implementation:**
```swift
import AVFoundation

class AdhanAudioManager: NSObject, ObservableObject {
    static let shared = AdhanAudioManager()
    private var audioPlayer: AVAudioPlayer?

    @Published var selectedReciter: Reciter = .default
    @Published var isDownloading: Bool = false
    @Published var downloadProgress: Double = 0.0

    enum Reciter: String, CaseIterable {
        case abdulBasit = "Abdul Basit"
        case misharyAlafasy = "Mishary Al-Afasy"
        case maherAlMuaiqly = "Maher Al-Muaiqly"
        case defaultBell = "Default Bell"

        var audioURL: URL {
            // Return URL to remote MP3 file
            URL(string: "https://cdn.example.com/adhan/\(rawValue).mp3")!
        }

        var localURL: URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("\(rawValue).mp3")
        }

        var isDownloaded: Bool {
            FileManager.default.fileExists(atPath: localURL.path)
        }
    }

    func downloadReciter(_ reciter: Reciter) async throws {
        isDownloading = true
        defer { isDownloading = false }

        let (localURL, _) = try await URLSession.shared.download(from: reciter.audioURL)
        try FileManager.default.moveItem(at: localURL, to: reciter.localURL)
    }

    func playAdhan(for prayer: Prayer.PrayerType) {
        guard selectedReciter.isDownloaded else {
            playDefaultSound()
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: selectedReciter.localURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play Adhan: \(error)")
            playDefaultSound()
        }
    }

    private func playDefaultSound() {
        // Play system bell sound as fallback
    }
}
```

**Settings Integration:**
```swift
Section("Adhan Audio") {
    Picker("Reciter", selection: $audioManager.selectedReciter) {
        ForEach(AdhanAudioManager.Reciter.allCases, id: \.self) { reciter in
            HStack {
                Text(reciter.rawValue)
                Spacer()
                if reciter.isDownloaded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Button("Download") {
                        Task {
                            try? await audioManager.downloadReciter(reciter)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    if audioManager.isDownloading {
        ProgressView(value: audioManager.downloadProgress)
            .progressViewStyle(.linear)
    }

    Toggle("Play Adhan at Prayer Time", isOn: $playAdhanEnabled)
}
```

**Test:**
- Select reciter, verify download starts
- Wait for download, verify checkmark appears
- Trigger notification at prayer time (change device time for testing)
- Verify Adhan audio plays automatically
- Test background audio (lock device, verify plays)
- Test with no internet (verify fallback sound)
- Test volume control
- Delete downloaded file, verify re-download works

---

### STEP 29 (v1.1.2): Tasbih Counter (Tap Mode)

**Status:** Planned | **Priority:** Medium | **Effort:** 3-4 hours

**Task:**
- Create digital Tasbih (dhikr) counter
- Tap anywhere on screen to increment counter
- Haptic feedback on each tap
- Preset goals: 33, 99, 100, 1000
- Celebration animation when goal reached
- History tracking (daily count)
- Reset button
- Segmented counter (e.g., count 33 three times for full Tasbih)

**Files to create:**
- `Views/Tasbih/TasbihView.swift`
- `ViewModels/TasbihViewModel.swift`
- `Models/TasbihSession.swift`

**Implementation:**
```swift
class TasbihViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var goal: Int = 33
    @Published var sessions: [TasbihSession] = []

    func increment() {
        count += 1
        HapticManager.shared.impact(.light)

        if count == goal {
            // Celebration!
            HapticManager.shared.notification(.success)
            showCelebration()
        }
    }

    func reset() {
        if count > 0 {
            sessions.append(TasbihSession(count: count, goal: goal, date: Date()))
        }
        count = 0
    }

    private func showCelebration() {
        // Trigger confetti animation
    }
}

struct TasbihView: View {
    @StateObject private var viewModel = TasbihViewModel()

    var body: some View {
        ZStack {
            // Tappable area (full screen)
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.increment()
                }

            VStack(spacing: 40) {
                // Count display
                Text("\(viewModel.count)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .scaleEffect(viewModel.count == 0 ? 1.0 : 1.1)
                    .animation(.spring(response: 0.3), value: viewModel.count)

                // Goal progress
                Text("\(viewModel.count) / \(viewModel.goal)")
                    .font(.title3)
                    .foregroundColor(.secondary)

                ProgressView(value: Double(viewModel.count), total: Double(viewModel.goal))
                    .progressViewStyle(.linear)
                    .frame(width: 200)

                Spacer()

                // Reset button
                Button(action: viewModel.reset) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("Tasbih")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Goal", selection: $viewModel.goal) {
                        Text("33").tag(33)
                        Text("99").tag(99)
                        Text("100").tag(100)
                        Text("1000").tag(1000)
                    }
                } label: {
                    Label("Goal", systemImage: "target")
                }
            }
        }
    }
}
```

**Test:**
- Tap screen, verify count increments
- Feel haptic feedback on each tap
- Reach goal (33), verify celebration animation
- Change goal to 99, reset, count again
- Test rapid tapping (100 taps), verify no lag
- View history, verify sessions saved
- Reset mid-count, verify session recorded

---

### STEP 30 (v1.1.3): Hijri Calendar Integration

**Status:** Planned | **Priority:** Medium | **Effort:** 4-5 hours

**Task:**
- Display current Hijri date prominently
- Month view showing Hijri calendar
- Highlight important Islamic dates:
  - Ramadan
  - Eid al-Fitr
  - Eid al-Adha
  - Ashura
  - Laylat al-Qadr (last 10 nights of Ramadan)
- Add descriptions for each important date
- Show countdown to next important date
- Integrate with prayer times view (already showing Hijri date)

**Files to create:**
- `Views/Calendar/HijriCalendarView.swift`
- `ViewModels/HijriCalendarViewModel.swift`
- `Models/IslamicDate.swift`
- `Services/IslamicDatesService.swift`

**Implementation:**
```swift
struct IslamicDate: Identifiable {
    let id = UUID()
    let name: String
    let arabicName: String
    let hijriMonth: Int
    let hijriDay: Int
    let description: String
    let significance: Significance

    enum Significance {
        case veryHigh  // Eid, Ramadan
        case high      // Laylat al-Qadr
        case medium    // Ashura
        case low       // Other dates
    }

    static let importantDates: [IslamicDate] = [
        IslamicDate(
            name: "Ramadan Begins",
            arabicName: "بداية رمضان",
            hijriMonth: 9,
            hijriDay: 1,
            description: "The holy month of fasting",
            significance: .veryHigh
        ),
        IslamicDate(
            name: "Laylat al-Qadr",
            arabicName: "ليلة القدر",
            hijriMonth: 9,
            hijriDay: 27,
            description: "The Night of Power",
            significance: .high
        ),
        IslamicDate(
            name: "Eid al-Fitr",
            arabicName: "عيد الفطر",
            hijriMonth: 10,
            hijriDay: 1,
            description: "Festival of Breaking the Fast",
            significance: .veryHigh
        ),
        IslamicDate(
            name: "Day of Arafah",
            arabicName: "يوم عرفة",
            hijriMonth: 12,
            hijriDay: 9,
            description: "Day before Eid al-Adha",
            significance: .high
        ),
        IslamicDate(
            name: "Eid al-Adha",
            arabicName: "عيد الأضحى",
            hijriMonth: 12,
            hijriDay: 10,
            description: "Festival of Sacrifice",
            significance: .veryHigh
        ),
        IslamicDate(
            name: "Ashura",
            arabicName: "عاشوراء",
            hijriMonth: 1,
            hijriDay: 10,
            description: "Day of Ashura",
            significance: .medium
        )
    ]
}

class HijriCalendarViewModel: ObservableObject {
    @Published var currentHijriDate: DateComponents = Calendar(identifier: .islamicUmAlQura).dateComponents([.year, .month, .day], from: Date())
    @Published var upcomingDates: [IslamicDate] = []

    func loadUpcomingDates() {
        let calendar = Calendar(identifier: .islamicUmAlQura)
        let today = calendar.dateComponents([.year, .month, .day], from: Date())

        upcomingDates = IslamicDate.importantDates
            .sorted { date1, date2 in
                // Sort by proximity to current date
                daysUntil(date1, from: today) < daysUntil(date2, from: today)
            }
            .prefix(5)
            .map { $0 }
    }

    private func daysUntil(_ islamicDate: IslamicDate, from today: DateComponents) -> Int {
        // Calculate days until Islamic date
        // Handle year wraparound
        var components = DateComponents()
        components.year = today.year
        components.month = islamicDate.hijriMonth
        components.day = islamicDate.hijriDay

        let calendar = Calendar(identifier: .islamicUmAlQura)
        guard let targetDate = calendar.date(from: components) else { return Int.max }
        guard let todayDate = calendar.date(from: today) else { return Int.max }

        var daysBetween = calendar.dateComponents([.day], from: todayDate, to: targetDate).day ?? 0

        // If date has passed, calculate for next year
        if daysBetween < 0 {
            components.year = (today.year ?? 1446) + 1
            guard let nextYearDate = calendar.date(from: components) else { return Int.max }
            daysBetween = calendar.dateComponents([.day], from: todayDate, to: nextYearDate).day ?? 0
        }

        return daysBetween
    }
}
```

**UI Design:**
```swift
struct HijriCalendarView: View {
    @StateObject private var viewModel = HijriCalendarViewModel()

    var body: some View {
        List {
            Section("Today") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.currentHijriDate.formatted())
                        .font(.title2)
                        .bold()
                    Text(Date().formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("Upcoming Important Dates") {
                ForEach(viewModel.upcomingDates) { date in
                    IslamicDateRow(date: date, daysUntil: viewModel.daysUntil(date))
                }
            }
        }
        .navigationTitle("Hijri Calendar")
        .onAppear {
            viewModel.loadUpcomingDates()
        }
    }
}

struct IslamicDateRow: View {
    let date: IslamicDate
    let daysUntil: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading) {
                    Text(date.name)
                        .font(.headline)
                    Text(date.arabicName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(daysUntil) days")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text("\(date.hijriMonth)/\(date.hijriDay)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Text(date.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}
```

**Test:**
- View calendar, verify current Hijri date shown
- Verify upcoming dates sorted by proximity
- Change device date to Ramadan period, verify highlighted
- Test countdown calculations (compare with IslamicFinder)
- Test year wraparound (dates in next Hijri year)
- Verify Arabic names display correctly
- Test in both light and dark mode

---

## Version 1.2 - Premium Experience (Month 2-3 post-launch)

**Timeline:** 1-2 weeks | **Effort:** 15-20 hours | **Release Target:** 2-3 months after v1.0 launch

**Goal:** Deliver exceptional premium features that justify continued engagement

### STEP 31 (v1.2.1): Apple Watch App

**Status:** Planned | **Priority:** High | **Effort:** 8-10 hours

**Task:**
- Create full watchOS companion app
- **Complications:** Show next prayer time on watch face
- **Qibla View:** Simple compass showing Qibla direction
- **Prayer Times List:** Today's 5 prayer times with countdown
- **Haptic feedback:** Alert at exact prayer time
- Sync data from iPhone using WatchConnectivity
- Support watch-only mode (calculate on watch if iPhone unavailable)
- Optimize for battery life (minimal background activity)

**Files to create:**
- `QiblaFinderWatch/QiblaFinderWatchApp.swift`
- `QiblaFinderWatch/ContentView.swift`
- `QiblaFinderWatch/CompassView.swift`
- `QiblaFinderWatch/PrayerListView.swift`
- `QiblaFinderWatch/Complications.swift`
- `Shared/WatchConnectivityManager.swift`

**Technical considerations:**
- Use WatchConnectivity for iPhone ↔ Watch sync
- Implement complications for all watch face families
- Handle location permission on watch
- Optimize for Series 4+ (larger screen)
- Test battery impact (target: < 5% per hour active use)

---

### STEP 32 (v1.2.2): Duas Collection

**Status:** Planned | **Priority:** Medium | **Effort:** 3-4 hours

**Task:**
- Curated collection of common duas (supplications)
- Categories: Morning, Evening, Before Sleep, After Prayer, Travel
- Arabic text + transliteration + translation
- Audio pronunciation for each dua
- Favorite/bookmark system
- Search functionality
- Share duas as image (social media ready)

**Duas to include:**
- Morning/Evening adhkar (remembrances)
- Ayat al-Kursi
- Last two verses of Surah Al-Baqarah
- Dua for travel
- Dua before eating
- Dua after prayer
- Istighfar (seeking forgiveness)

---

### STEP 33 (v1.2.3): Tasbih Voice Mode

**Status:** Planned | **Priority:** Low | **Effort:** 4-5 hours

**Task:**
- Voice-activated Tasbih counter
- Say "Subhanallah", "Alhamdulillah", "Allahu Akbar" to increment
- Uses Speech Recognition framework
- Real-time phrase detection
- Count different phrases separately or together
- Privacy: All processing on-device, no data sent to servers
- Works in background (low power mode)

---

## Version 1.3 - Community Features (Month 4-5 post-launch)

**Timeline:** 2 weeks | **Effort:** 20-25 hours | **Release Target:** 4-5 months after v1.0 launch

### STEP 34 (v1.3.1): Mosque Finder

**Status:** Conceptual | **Priority:** High | **Effort:** 10-12 hours

**Task:**
- MapKit integration showing nearby mosques
- Search radius: 1km, 5km, 10km, 50km
- Display mosque info: name, address, phone, website
- Directions integration (Apple Maps)
- User-submitted mosque database (moderated)
- Prayer time adjustments (some mosques pray early/late)
- User reviews and photos (optional)

---

### STEP 35 (v1.3.2): Prayer Tracking & Analytics

**Status:** Conceptual | **Priority:** Medium | **Effort:** 8-10 hours

**Task:**
- Track prayers completed each day
- Visual calendar showing prayer history
- Statistics: On-time percentage, streak tracking
- Motivational reminders
- Privacy-first: All data stored locally, no cloud sync
- Export data as CSV for personal records

---

### STEP 36 (v1.3.3): Ramadan Special Mode

**Status:** Conceptual | **Priority:** Medium | **Effort:** 5-6 hours

**Task:**
- Activate automatically during Ramadan month
- Suhoor/Iftar countdown timers
- Taraweeh prayer reminder
- Daily Ramadan tips
- Customized theme (crescent moon icon)
- Special notifications for last 10 nights (Laylat al-Qadr)

---

## Version 1.4 - Advanced Features (Month 6+ post-launch)

**Timeline:** 3+ weeks | **Effort:** 30-40 hours | **Release Target:** 6+ months after v1.0 launch

### STEP 37 (v1.4.1): AR Qibla Mode

**Status:** Conceptual | **Priority:** High | **Effort:** 12-15 hours

**Task:**
- Use ARKit to show Qibla direction in camera view
- Point phone at horizon, see arrow overlay
- Works like AR compass but more immersive
- Handles varying terrain (hills, buildings)
- Requires A12 Bionic chip or newer (iPhone XS+)

---

### STEP 38 (v1.4.2): Enhanced Widgets

**Status:** Conceptual | **Priority:** Medium | **Effort:** 6-8 hours

**Task:**
- Lock Screen widgets (iOS 16+)
- Interactive widgets (iOS 17+)
- Larger widget sizes showing full prayer schedule
- Customizable widget content (choose what to display)
- Live Activities for ongoing prayer time countdown

---

### STEP 39 (v1.4.3): Siri Shortcuts Integration

**Status:** Conceptual | **Priority:** Low | **Effort:** 4-5 hours

**Task:**
- "Hey Siri, when is the next prayer?"
- "Hey Siri, show me Qibla direction"
- "Hey Siri, open Tasbih counter"
- Donate intents to Siri for suggestion
- Create custom shortcuts in Shortcuts app

---

## Architecture Documentation

After each major milestone (every 5 steps), update `memory-bank/architecture.md` with:
- What files were created/modified
- What each component does
- How components connect and communicate
- Data flow diagrams (ASCII art)
- Important decisions made and why
- Known limitations or technical debt

## Progress Tracking

After each step completion, update `memory-bank/progress.md` with:
- Step number completed
- Date completed
- Time spent
- Any issues encountered and how solved
- Any deviations from plan
- Next steps
- Blockers (if any)

---

## Development Workflow

1. **Read the step** - Understand requirements fully
2. **Create files** - Follow exact file structure
3. **Implement features** - Write clean, documented code
4. **Test thoroughly** - Run all tests in the step
5. **Update docs** - Update architecture.md and progress.md
6. **Commit** - Git commit with clear message
7. **Next step** - Move to next step

## Code Quality Standards

- **Comments:** Add comments for complex logic
- **Naming:** Use clear, descriptive names (follow conventions)
- **Functions:** Keep functions small and focused
- **Error handling:** Always handle errors gracefully
- **Performance:** Optimize where needed (measure first)
- **Accessibility:** Use proper labels for VoiceOver
- **Testing:** Write tests for business logic

## Git Commit Messages Format

```
Step X: [Short description]

- Bullet points of what changed
- Reference to implementation plan

Files modified:
- path/to/file1.swift
- path/to/file2.swift
```

---

**Total Steps: 35** (including sub-steps)
**Estimated Time: 6-8 weeks** (solo developer, part-time)
**Complexity: High** (comprehensive app with premium features)

This is a complete, production-ready MVP with all premium features included. Ready to execute step by step!
