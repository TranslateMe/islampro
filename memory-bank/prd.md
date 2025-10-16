# Qibla Finder - Product Requirements Document v3 (Maximized MVP)

## Overview
A beautiful, fast, and ad-free iOS app that helps Muslims find the Qibla direction (toward Mecca) anywhere in the world. Premium features unlock notifications, widgets, themes, and more.

## Core Problem
Existing Qibla apps are cluttered with ads, slow to load, bloated with unnecessary features, and have poor user experience. Muslims need a simple, reliable tool they use 5+ times daily for prayer.

## Target Users
- Primary: Practicing Muslims who pray 5 times daily (ages 18-65)
- Secondary: Travelers needing quick Qibla direction
- Tertiary: People in unfamiliar locations (hotels, airports, outdoors)

## User Flows

### First Launch Flow
1. App opens → Onboarding (3 pages: Welcome, Location Permission, How to Use)
2. User taps modern location button → Permission granted
3. Shows compass immediately
4. Bottom tabs show: Qibla | Prayer Times | Map | Settings

### Daily Use Flow
1. User opens app (< 1 second launch)
2. App opens directly to compass
3. User rotates phone until Kaaba pointer aligns
4. Haptic feedback when aligned
5. User prays

### Premium Purchase Flow
1. User explores premium features in Settings
2. Taps "Unlock Premium - $2.99"
3. Sees paywall with feature list
4. Purchases via StoreKit 2
5. All premium features unlock immediately
6. One-time purchase, no subscription

## Core Features (FREE)

### 1. Qibla Compass Screen
**Visual Design:**
- Full-screen circular compass (fills 70% of screen height)
- Compass ring: Thin border with N/S/E/W markers + 30° degree markers
- Center: Kaaba icon (gold #FFD700) on semi-transparent circle
- Top: Degree indicator with background blur (e.g., "285° NW")
- Bottom: Distance to Mecca in km (formatted with commas)
- Top-right: Accuracy indicator (green/yellow/red dot)
- Background: Gradient (adapts to light/dark mode and themes)

**Behavior:**
- Smooth 60fps rotation as device rotates
- Haptic feedback when pointing within ±5° of Qibla
- Accuracy indicator shows calibration status
- Works entirely offline
- Entrance animation (fade + scale)

### 2. Prayer Times Screen
**Visual Design:**
- List of 5 prayers with times (Fajr, Dhuhr, Asr, Maghrib, Isha)
- Each row: Prayer name (English + Arabic), time, countdown
- Highlighted row = next prayer (green accent background, bold)
- Header: Location name, Hijri date, Gregorian date
- Bottom: Calculation method label

**Behavior:**
- Updates every second (live countdown)
- Automatically highlights next prayer
- Shows "Now" if within prayer time window
- Shows "in Xh Xm" countdown
- Pull to refresh
- Staggered fade-in animation for rows

### 3. Map View (NEW - MVP Enhancement)
**Visual Design:**
- Full-screen MapKit map
- Blue dot: User location
- Gold Kaaba icon: Mecca location
- Line connecting user to Mecca (great circle path)
- Bottom overlay: Distance label with blur background

**Behavior:**
- Centered to show both user and Mecca
- Zoom controls
- Updates when location changes
- Zoom animation on appear

### 4. Settings Screen (NEW - MVP Enhancement)
**Visual Design:**
- List with sections:
  - Prayer Calculations (default: Muslim World League)
  - Theme (shows Premium badge if not purchased)
  - Notifications (shows Premium badge if not purchased)
  - About (app version, rate app, privacy policy, contact)
  - Premium section (purchase button or "Premium Active" badge)

**Behavior:**
- Calculation method free (defaults to Muslim World League)
- Premium features show upgrade prompt
- Rate app opens App Store
- Settings persist in UserDefaults

### 5. Location Handling
- Modern CoreLocationUI button (better UX, builds trust)
- Auto-request location on first launch (via onboarding)
- Cache last known location in UserDefaults (works offline for 24h)
- Show location name (city) at top of prayer times
- Recalculate when location changes significantly (> 50km)
- Handle permission denied gracefully (PermissionView with "Open Settings")

### 6. Offline Mode
- All calculations done locally (no internet needed)
- Prayer times calculated for 7 days ahead (cached)
- Compass works entirely offline
- Cached location used if GPS unavailable
- Shows "Using last known location" when offline

### 7. Onboarding (First Launch)
**3-Page Onboarding:**
- **Page 1:** Welcome + app purpose (Kaaba icon)
- **Page 2:** Location permission explanation (modern LocationButton)
- **Page 3:** How to use compass + haptic feedback explanation
- Swipe navigation with page indicators
- "Get Started" button on final page
- Never shows again (UserDefaults flag)

### 8. Localization
- **English (en):** Primary language
- **Arabic (ar):** Full RTL (right-to-left) support
  - All UI strings translated
  - Layout flips automatically
  - Prayer names in Arabic from Adhan library
  - Hijri month names in Arabic
  - Compass stays centered (not affected by RTL)

### 9. Dark Mode
- Full dark mode support
- Adapts instantly (no restart needed)
- Custom color sets in Assets.xcassets
- Gradient backgrounds adapt
- All text readable in both modes

---

## Premium Features ($2.99 one-time)

### Why One-Time vs Subscription?
**Ethical:** Religious tool shouldn't extract recurring fees
**User Trust:** Higher conversion rate for one-time purchase
**App Store:** Less churn, better ratings
**Target Conversion:** > 8% (religious users support ethical apps)

### Premium Feature List:

### 1. Prayer Notifications
- Local notifications 5 minutes before each prayer (customizable: 0-30 min)
- Shows prayer name and time
- Toggle per-prayer notifications
- Custom sounds (default system sound)
- Updates daily (recalculates prayer times)
- Handles timezone changes automatically

### 2. Home Screen Widget
- **Small widget:** Next prayer name + countdown
- **Medium widget:** Next prayer + all 5 prayer times
- Updates every minute via WidgetKit timeline
- Tapping widget opens main app
- Uses App Groups for data sharing
- Adapts to light/dark mode

### 3. Multiple Calculation Methods
- **Free default:** Muslim World League
- **Premium unlocks:**
  - ISNA (Islamic Society of North America)
  - Umm al-Qura (Makkah) - Used in Saudi Arabia
  - Egyptian General Authority
  - University of Karachi
  - Dubai, Kuwait, Qatar, Singapore, Tehran
  - Custom adjustments
- Each method shows description
- Prayer times update when method changed
- Saved in UserDefaults

### 4. Custom Themes & Accent Colors
- **Predefined themes:**
  - Default (green)
  - Ocean (blue gradient)
  - Forest (green gradient)
  - Sunset (orange/pink gradient)
- **Custom theme:** ColorPicker for accent color
- Applies throughout app:
  - Tab bar accent
  - Buttons
  - Highlights
  - Compass gradient background
  - Prayer time next prayer highlight
- Theme persists in UserDefaults

### 5. Apple Watch App (Optional - Time Permitting)
- **Watch face:** Qibla compass (uses watch orientation)
- **Complications:** Show next prayer time + countdown
- **Prayer list:** Today's 5 prayers
- Syncs via WatchConnectivity with iPhone
- Haptic feedback on alignment
- Works standalone if needed
- **Note:** May be post-launch if time constrained

---

## Design System

### Colors
- **Primary:** Green (#34C759 - iOS system green)
- **Accent Gold:** #FFD700 (Kaaba icon)
- **Background Light:** White (#FFFFFF)
- **Background Dark:** Black (#000000)
- **Text Light:** Black (#000000)
- **Text Dark:** White (#FFFFFF)
- **Secondary Text:** Gray (system)
- **Success:** Green (#34C759)
- **Warning:** Yellow (#FFCC00)
- **Error:** Red (#FF3B30)

### Typography
- **Headers:** SF Pro Display Bold, 24-32pt
- **Body:** SF Pro Text Regular, 17pt
- **Arabic:** System Arabic (SF Arabic) - auto-selected
- **Monospace:** SF Mono (for countdown timers)

### Icons
- **Kaaba:** SF Symbol "building.2.fill" (gold)
- **Location:** "location.fill"
- **Compass:** "location.north.fill"
- **Clock:** "clock.fill"
- **Map:** "map.fill"
- **Settings:** "gearshape.fill"
- **Notifications:** "bell.fill"
- **Widget:** "widget.small"
- **Watch:** "applewatch"
- **Theme:** "paintpalette.fill"

### Animations
- **Entrance:** Fade + scale (0.6s spring)
- **Tab switches:** Fade transition
- **Compass:** 60fps rotation (0.2s easeOut)
- **Prayer highlight:** Animated when next prayer changes
- **Buttons:** Scale on press (0.1s easeInOut)
- **Errors:** Shake animation
- **Loading:** Skeleton screens with .redacted modifier

### Haptic Feedback
- **Qibla alignment:** Medium impact (once when aligned)
- **Tab selection:** Light impact
- **Button taps:** Selection feedback
- **Success actions:** Notification success
- **Errors:** Notification error

## Technical Requirements
- iOS 17.0+ (latest SwiftUI features)
- Swift 5.9 (Xcode 15.0.1)
- SwiftUI (no UIKit)
- CoreLocation for GPS
- CoreLocationUI for modern location button
- CoreMotion for compass/magnetometer
- MapKit for map view
- UserNotifications for prayer alerts (premium)
- WidgetKit for home screen widget (premium)
- WatchKit for Apple Watch (premium, optional)
- StoreKit 2 for in-app purchase
- < 20MB app size (with premium features)
- Launches in < 0.8 seconds on iPhone 12+
- 60fps compass animation
- No network requests (fully offline)

## Privacy
- **Location:** "When In Use" only (not "Always")
- No data collection
- No analytics
- No third-party SDKs
- No ads (ever)
- Privacy-first design
- Location cached locally only (cleared after 24h)

## Monetization Strategy

### Free Version (Always Free)
- Full Qibla compass (unlimited)
- Prayer times (unlimited)
- Map view showing Mecca
- Settings and customization
- Ad-free (always)
- No nag screens

### Premium ($2.99 one-time)
- Prayer notifications
- Home screen widget
- Apple Watch app (optional)
- Multiple calculation methods
- Custom themes
- "Support the developer" feeling

### Why This Works:
- **Ethical:** One-time feels right for religious tool
- **Conversion:** 8-10% expected (higher than subscriptions for this demographic)
- **Retention:** No churn, users own it forever
- **Reviews:** Better ratings (no "greedy developer" complaints)
- **Revenue:** With 10K downloads, 8% conversion = 800 × $2.99 = $2,392

## Success Metrics
- **Daily Active Users (DAU):** Target 70% (people pray daily)
- **Session length:** 10-30 seconds average (quick use = good design)
- **Crash-free rate:** > 99.5%
- **App Store rating:** > 4.7 stars
- **Premium conversion:** > 8% (religious users support ethical apps)
- **Launch time:** < 800ms (measured)
- **Compass FPS:** 60fps constant

## Out of Scope (Future Versions)

### Version 1.1+
- Quran reader integration
- Dhikr counter
- Qibla sharing (social features)
- Nearby mosques finder with walking directions
- AR camera overlay (ARKit)
- Critical alerts (bypass silent mode)
- Notification actions (mark as prayed, snooze)
- Customizable notification sounds

### Future Platforms
- iPad optimization
- macOS version (Catalyst)
- visionOS (Apple Vision Pro)
- Siri Shortcuts integration
- Live Activities (Dynamic Island)
- Lock screen widgets (iOS 16+)

## Competitive Analysis

### Existing Apps Problems:
- **Muslim Pro:** Cluttered with ads, subscription required ($39.99/year), slow
- **Qibla Finder:** Ugly UI, inaccurate compass, banner ads
- **Athan:** Too many features (Quran, Dhikr, etc.), slow to load
- **Al-Moazin:** Outdated design, inconsistent prayer times

### Our Differentiators:
1. **Beautiful, minimal design** - Looks like a first-party Apple app
2. **Fast** - < 1 second launch, no loading screens
3. **Accurate compass** - 60fps smooth rotation, ±5° accuracy
4. **Ethical monetization** - One-time purchase, not subscription
5. **Privacy-first** - No data collection, no analytics, no tracking
6. **Offline always** - No internet required
7. **Modern iOS** - iOS 17+, uses latest SwiftUI features
8. **Full Arabic support** - Complete RTL layout, not just translation
9. **Premium features** - Notifications, widget, watch app, themes

## App Store Optimization (ASO)

### Name & Subtitle
- **Name:** QiblaFinder
- **Subtitle:** Fast & Accurate Qibla Compass

### Keywords (100 characters max)
```
qibla, compass, prayer, times, islamic, muslim, mecca, kaaba, salat, namaz, direction, mosque
```

### Description (First 3 lines critical)
```
Find the exact direction to Mecca from anywhere in the world.

QiblaFinder is a beautiful, fast, and accurate Qibla compass for Muslims.
No ads, no tracking, works offline.

FEATURES:
• Accurate Qibla Compass - 60fps smooth rotation
• Prayer Times - For all 5 daily prayers
• Interactive Map - See your location relative to Mecca
• Offline Mode - Works without internet
• Dark Mode - Beautiful in light and dark
• Arabic Support - Full RTL layout

PREMIUM ($2.99 one-time):
• Prayer Notifications - Never miss a prayer
• Home Screen Widget - See next prayer at a glance
• Apple Watch App - Qibla on your wrist
• Multiple Calculation Methods - Choose your preferred method
• Custom Themes - Personalize your experience

Perfect for Muslims who pray 5 times daily and need a reliable, fast, and
beautiful Qibla finder.

Privacy-first: No data collection. No tracking. No analytics.
Ethical: One-time purchase, not a subscription.
Fast: Launches in under 1 second.

Download QiblaFinder today and never miss the Qibla direction again.
```

### Screenshots (6.7" and 5.5" required)
1. **Hero:** Compass view showing aligned Kaaba pointer
2. **Prayer Times:** List with next prayer highlighted
3. **Map View:** Showing user and Mecca with distance
4. **Premium Features:** Paywall showcasing all premium features
5. **Dark Mode:** Compass in dark mode (beautiful gradient)
6. **Widget:** Home screen showing prayer time widget

### App Preview Video (Optional)
- 15-30 seconds
- Show: Open app → Compass rotates → Haptic feedback → Switch to prayer times → Premium features

## Launch Checklist

### Pre-Launch
- [ ] All 35 implementation steps completed
- [ ] Unit tests pass (> 80% coverage)
- [ ] Device testing on real iPhone
- [ ] Performance targets met (< 800ms launch, 60fps)
- [ ] Dark mode tested thoroughly
- [ ] Arabic localization tested (full RTL)
- [ ] Premium purchase flow tested (sandbox)
- [ ] Widget tested on home screen
- [ ] App icon finalized (1024x1024)
- [ ] Screenshots created (6.7" and 5.5")
- [ ] Privacy policy written and hosted
- [ ] App Store listing complete

### TestFlight Beta
- [ ] Upload to TestFlight
- [ ] Invite 10-25 beta testers
- [ ] Collect feedback
- [ ] Fix critical bugs
- [ ] Test sandbox in-app purchase

### App Store Submission
- [ ] Archive and upload to App Store Connect
- [ ] Configure in-app purchase product
- [ ] Submit for review
- [ ] Monitor review status
- [ ] Respond to App Review questions

### Post-Launch
- [ ] Monitor crash reports
- [ ] Track App Store ratings
- [ ] Respond to user reviews
- [ ] Collect feature requests
- [ ] Plan version 1.1 features
- [ ] Market app (social media, communities)

---

## Risk Assessment

### Technical Risks
- **Compass accuracy:** Magnetic interference in some environments
  - **Mitigation:** Show accuracy indicator, allow calibration
- **Battery drain:** Continuous sensor usage
  - **Mitigation:** Optimize sensor polling, test thoroughly
- **iOS version adoption:** iOS 17+ limits audience
  - **Mitigation:** iOS 17 adoption > 80% by launch (late 2024)

### Business Risks
- **Low conversion rate:** Users don't purchase premium
  - **Mitigation:** Strong free version, clear premium value
- **Competition:** Existing apps have large user bases
  - **Mitigation:** Superior UX, ethical pricing, word-of-mouth
- **App Review rejection:** StoreKit or permission issues
  - **Mitigation:** Follow Apple guidelines strictly

### Mitigation Strategy
- Launch strong free version first
- Add premium features in updates if needed
- Build word-of-mouth through quality
- Engage with Muslim tech communities
- Collect early feedback via TestFlight

---

**Version:** 3.0 (Maximized MVP)
**Last Updated:** January 2025
**Status:** Ready for Implementation
**Estimated Timeline:** 6-8 weeks (solo developer, part-time)
**Target Launch:** Q1 2025
