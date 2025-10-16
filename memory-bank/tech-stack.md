# Qibla Finder - Tech Stack v3 (Maximized MVP)

## Platform & Requirements
- **Language:** Swift 5.9 (Xcode 15.0.1 compatible)
- **Framework:** SwiftUI (pure, no UIKit)
- **Minimum iOS:** 17.0
- **Xcode:** 15.0+
- **Target Devices:** iPhone only (iPad later)
- **watchOS:** Optional Apple Watch companion app

## Core Apple Frameworks

### Location & Sensors
```swift
import CoreLocation      // GPS coordinates
import CoreLocationUI    // Modern location button (iOS 17+)
import CoreMotion        // Magnetometer/compass
```

### UI & Data
```swift
import SwiftUI           // All UI
import Combine           // Reactive streams
import MapKit            // Map view showing user + Mecca
```

### Premium Features
```swift
import StoreKit          // In-app purchases (StoreKit 2)
import UserNotifications // Prayer time notifications
import WidgetKit         // Home screen widget
import WatchKit          // Apple Watch app (optional)
import WatchConnectivity // iPhone ↔ Watch sync
```

## Third-Party Dependencies

### Prayer Time Calculation
**Package:** Adhan Swift
**URL:** https://github.com/batoulapps/adhan-swift
**Version:** 1.x.x
**Why:** Industry-standard, accurate Islamic prayer time calculations
**License:** MIT

```swift
// Add via SPM (Swift Package Manager)
.package(url: "https://github.com/batoulapps/adhan-swift", from: "1.0.0")
```

**Features used:**
- Multiple calculation methods (Muslim World League, ISNA, Umm al-Qura, etc.)
- Accurate prayer times for worldwide locations
- Handles edge cases (high latitude, DST)

## Project Structure

```
QiblaFinder/
├── QiblaFinderApp.swift          // App entry point
├── ContentView.swift              // Main 4-tab view
│
├── Views/
│   ├── Compass/
│   │   ├── CompassView.swift               // Main compass screen
│   │   ├── CompassRingView.swift           // Compass circle UI
│   │   ├── QiblaPointerView.swift          // Kaaba pointer
│   │   └── AccuracyIndicatorView.swift     // Calibration status
│   │
│   ├── PrayerTimes/
│   │   ├── PrayerTimesView.swift           // Prayer times list
│   │   ├── PrayerRowView.swift             // Individual prayer row
│   │   └── NextPrayerHeaderView.swift      // Next prayer highlight
│   │
│   ├── Map/
│   │   ├── MapView.swift                   // MapKit view (user + Mecca)
│   │   └── MapViewModel.swift              // Map business logic
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift              // Settings screen
│   │   ├── PaywallView.swift               // Premium purchase screen
│   │   └── ThemePickerView.swift           // Theme selection (premium)
│   │
│   ├── Onboarding/
│   │   └── OnboardingView.swift            // First launch onboarding (3 pages)
│   │
│   └── Shared/
│       ├── PermissionView.swift            // Location permission prompt
│       └── ErrorView.swift                 // Error states
│
├── ViewModels/
│   ├── CompassViewModel.swift              // Compass business logic
│   ├── PrayerTimesViewModel.swift          // Prayer times business logic
│   └── MapViewModel.swift                  // Map business logic
│
├── Models/
│   ├── Prayer.swift                        // Prayer data model
│   ├── QiblaDirection.swift                // Qibla bearing model
│   ├── LocationData.swift                  // Location data model
│   └── Theme.swift                         // Theme model (premium)
│
├── Services/
│   ├── LocationManager.swift               // GPS + location services
│   ├── CompassManager.swift                // Magnetometer + heading
│   ├── QiblaCalculator.swift               // Qibla bearing math
│   ├── PrayerTimeCalculator.swift          // Prayer time calculations (using Adhan)
│   ├── HijriDateService.swift              // Hijri calendar conversion
│   ├── StoreManager.swift                  // In-app purchase (StoreKit 2)
│   ├── NotificationManager.swift           // Prayer notifications (premium)
│   ├── SettingsManager.swift               // UserDefaults persistence
│   ├── ThemeManager.swift                  // Theme management (premium)
│   └── WatchConnectivityManager.swift      // iPhone ↔ Watch sync (optional)
│
├── Utilities/
│   ├── Constants.swift                     // App constants (Mecca coords, colors)
│   ├── Extensions.swift                    // Swift extensions (String, Date, Double, Color)
│   └── HapticManager.swift                 // Haptic feedback
│
├── Resources/
│   ├── Assets.xcassets                     // Images, colors, app icon
│   ├── en.lproj/
│   │   └── Localizable.strings             // English strings
│   └── ar.lproj/
│       └── Localizable.strings             // Arabic strings (full RTL support)
│
├── QiblaWidget/ (Widget Extension)
│   ├── QiblaWidget.swift                   // Widget configuration
│   ├── QiblaWidgetView.swift               // Widget UI
│   └── WidgetProvider.swift                // Timeline provider
│
└── QiblaFinderWatch/ (watchOS Target - Optional)
    ├── QiblaFinderWatchApp.swift           // Watch app entry
    ├── ContentView.swift                   // Watch main view
    ├── CompassView.swift                   // Watch compass
    ├── PrayerTimesView.swift               // Watch prayer times
    └── Complications/
        └── ComplicationController.swift    // Watch face complications
```

## Architecture: MVVM + Combine

```
View (SwiftUI)
    ↕
 ViewModel (ObservableObject) — @Published properties
    ↕
Service/Manager (Business logic) — Combine publishers
    ↕
Model (Data structures)
```

**Example Flow:**
```
CompassView
  → observes CompassViewModel (@StateObject)
    → combines LocationManager.$currentLocation + CompassManager.$heading
      → uses QiblaCalculator to compute bearing
        → publishes QiblaDirection model
          → View updates UI reactively
```

## Key Technical Decisions

### 1. Why SwiftUI Only?
- Modern, declarative UI
- Built-in animations
- Dark mode automatic
- Less code than UIKit
- Native iOS 17+ features
- Better performance with @Published

### 2. Why Combine?
- Reactive sensor data streams (location, compass)
- Clean async handling
- Pairs perfectly with SwiftUI @Published
- Replaces need for NotificationCenter

### 3. Why No Backend?
- **Faster:** No network calls = instant response
- **Offline:** Works anywhere, anytime
- **Privacy:** No data leaves device
- **Cost:** No server costs
- **Reliability:** No API downtime

### 4. Why StoreKit 2 (not StoreKit 1)?
- Modern async/await API
- Simpler receipt validation
- Built-in transaction verification
- Better App Store Server integration

### 5. Why One-Time Premium vs Subscription?
- **Ethical:** Religious tool shouldn't extract recurring fees
- **User Trust:** Higher conversion rate for one-time purchase
- **App Store:** Less churn, better ratings
- **Technical:** Simpler to implement

## Calculations Strategy

### Qibla Bearing
- **Algorithm:** Great Circle formula (Haversine)
- **Implementation:** Pure Swift math
- **Inputs:** User coordinates (lat/lon), Mecca coordinates
- **Output:** Bearing in degrees (0-360)
- **Accuracy:** ±1° typical

```swift
// Simplified formula:
let Δλ = meccaLon - userLon
let θ = atan2(sin(Δλ) * cos(meccaLat),
             cos(userLat) * sin(meccaLat) - sin(userLat) * cos(meccaLat) * cos(Δλ))
let bearing = (θ.toDegrees() + 360) % 360
```

### Prayer Times
- **Library:** Adhan Swift
- **Methods:** Muslim World League (default), ISNA, Umm al-Qura, etc.
- **Calculation:** All local (no API calls)
- **Storage:** Cache today's times in UserDefaults
- **Update:** Recalculate at midnight or location change > 50km

### Hijri Date
- **API:** Foundation's `Calendar(identifier: .islamicUmAlQura)`
- **Accuracy:** Official Umm al-Qura calendar
- **Format:** "15 Ramadan 1446"
- **Localization:** Supports English and Arabic month names

## Performance Targets

- **Launch time:** < 800ms (cold start)
- **Compass FPS:** 60fps constant (no dropped frames)
- **Memory:** < 50MB typical usage
- **Battery:** < 1% drain per 5-minute session
- **App size:** < 20MB download (with premium features)
- **Location:** < 500ms to first fix (warm start)
- **Compass:** < 100ms update latency

## Testing Strategy

### Unit Tests
- **QiblaCalculator:** Test bearing for known locations
- **PrayerTimeCalculator:** Verify times match IslamicFinder.org
- **Extensions:** Test cardinal directions, date formatting, Hijri conversion
- **Target Coverage:** > 80% for Services/ and Utilities/

### UI Tests
- **Compass rotation:** Verify smooth animation
- **Prayer times display:** Verify countdown updates
- **Tab navigation:** Verify all tabs accessible
- **Premium flow:** Verify purchase unlocks features

### Device Testing (Physical iPhone Required)
- **Compass accuracy:** Test with real magnetometer
- **Location accuracy:** Test in multiple locations
- **Haptic feedback:** Verify vibration on alignment
- **Battery drain:** Monitor during extended use
- **Offline mode:** Test airplane mode

### Localization Testing
- **Arabic RTL:** Verify full right-to-left layout
- **String coverage:** All UI strings localized
- **Date formats:** Verify locale-aware formatting

## Design Patterns

### MVVM (Model-View-ViewModel)
- **Views:** Pure SwiftUI, no business logic
- **ViewModels:** ObservableObject, @Published properties
- **Models:** Struct (value types), Codable for persistence
- **Services:** Singleton or injected, handle I/O

### Dependency Injection
```swift
class CompassViewModel: ObservableObject {
    let locationManager: LocationManager
    let compassManager: CompassManager
    let qiblaCalculator: QiblaCalculator

    init(locationManager: LocationManager = .shared,
         compassManager: CompassManager = .shared,
         qiblaCalculator: QiblaCalculator = .init()) {
        self.locationManager = locationManager
        self.compassManager = compassManager
        self.qiblaCalculator = qiblaCalculator
    }
}
```

### Observable Pattern (Combine)
- Use `@Published` for reactive state
- Use `Publishers.CombineLatest` to merge streams
- Use `.sink` for side effects
- Use `.assign` for property updates

### Single Responsibility
- Each file has one clear purpose
- Services don't know about UI
- ViewModels don't know about SwiftUI
- Models are pure data

## Naming Conventions

- **Files:** PascalCase (CompassView.swift)
- **Classes/Structs:** PascalCase (LocationManager, Prayer)
- **Properties/Variables:** camelCase (qiblaDirection, isNext)
- **Constants:** UPPERCASE (MECCA_LATITUDE)
- **ViewModels:** Suffix with ViewModel (CompassViewModel)
- **Managers:** Suffix with Manager (LocationManager)
- **Services:** Suffix with Service or Manager
- **Extensions:** Descriptive (Double+Formatting.swift)

## Localization

### Supported Languages (MVP)
1. **English (en)** - Primary
2. **Arabic (ar)** - Full RTL support

### RTL Layout Strategy
- Use `.leading` / `.trailing` instead of `.left` / `.right`
- SwiftUI auto-flips layouts based on locale
- Compass stays centered (not affected by RTL)
- Test with Arabic language in Settings

### String Management
- All user-facing strings in `Localizable.strings`
- Use `NSLocalizedString("key", comment: "description")`
- Prayer names come from Adhan library (auto-localized)

## Premium Features Architecture

### Feature Gating
```swift
class StoreManager: ObservableObject {
    @Published var isPremium: Bool = false

    func checkPremiumStatus() {
        // Check StoreKit receipt
        // Set isPremium flag
    }
}

// In views:
@EnvironmentObject var storeManager: StoreManager

if storeManager.isPremium {
    // Show premium feature
} else {
    // Show upgrade prompt
}
```

### Premium Features List
1. **Prayer Notifications** - UserNotifications framework
2. **Home Screen Widget** - WidgetKit + App Groups
3. **Multiple Calculation Methods** - Adhan library methods
4. **Custom Themes** - ThemeManager + UserDefaults
5. **Apple Watch App** - WatchKit + WatchConnectivity (optional)

### Data Sharing (Widget ↔ Main App)
- **Mechanism:** App Groups + Shared UserDefaults
- **App Group ID:** `group.com.qiblafinder.app`
- **Shared Data:** Prayer times, location, settings
- **Update Frequency:** Widget timeline updates every minute

## Security & Privacy

### Location Data
- **Permission:** "When In Use" only (not "Always")
- **Storage:** Cache last location in UserDefaults (cleared after 24h)
- **Sharing:** Never sent to external servers
- **Usage:** Only for Qibla + prayer time calculation

### No Third-Party SDKs
- No analytics (Firebase, Mixpanel, etc.)
- No crash reporting (Crashlytics, Sentry, etc.)
- No ad networks
- Only Apple frameworks

### In-App Purchase
- **Receipt Validation:** StoreKit 2 auto-verifies
- **Storage:** Premium status in UserDefaults + Keychain
- **Restoration:** Automatic via StoreKit transaction history

## Build Configuration

### Debug
- Debug symbols enabled
- Fast compiler optimization (-Onone)
- All logging enabled

### Release
- Optimizations enabled (-O)
- Strip debug symbols
- Minimal logging
- App thinning enabled

### App Store Distribution
- Bitcode: Not required (deprecated iOS 14+)
- Architecture: arm64 only (no 32-bit)
- Minimum iOS: 17.0
- App Category: Utilities
- Age Rating: 4+ (no objectionable content)

## Version Control

### Git Strategy
- **Main branch:** Production-ready code
- **Feature branches:** `feature/step-X-description`
- **Commit format:** "Step X: Description"
- **Commit frequency:** After each step completion

### .gitignore
```
# Xcode
*.xcuserstate
*.xcworkspace/xcuserdata/
DerivedData/

# SPM
.swiftpm/
.build/

# MacOS
.DS_Store

# Secrets (if any)
.env
secrets.plist
```

## Deployment

### TestFlight
- Beta testing before App Store release
- Invite 10-25 testers
- Test sandbox in-app purchase
- Collect feedback on performance and UX

### App Store Connect
- App ID: com.qiblafinder.app
- Primary Language: English
- Category: Utilities
- Privacy Policy: Required (host on GitHub Pages or website)
- In-App Purchase Product ID: com.qiblafinder.premium

### App Store Assets
- App Icon: 1024x1024 PNG
- Screenshots: 6.7" and 5.5" required
- App Preview Video: Optional
- Keywords: qibla, compass, prayer, times, islam, muslim, mecca

---

## Future Tech Considerations

### Version 2.x Potential Additions
- **ARKit:** AR compass overlay on camera
- **HealthKit:** Track prayer times as mindfulness
- **Siri Shortcuts:** "Hey Siri, when is next prayer?"
- **Live Activities:** Dynamic Island prayer countdown (iOS 16.1+)
- **Lock Screen Widgets:** iOS 16+ lock screen support

### Platform Expansion
- **iPad:** Optimize for larger screens
- **macOS:** Catalyst app (if viable)
- **visionOS:** Apple Vision Pro support (future)

---

**Last Updated:** Implementation Plan v3 (Maximized MVP)
**Total Dependencies:** 1 (Adhan Swift only)
**Total Frameworks:** 13 Apple frameworks
**Estimated Binary Size:** < 20MB
**Target Audience:** Muslims worldwide (1.8B+ potential users)
