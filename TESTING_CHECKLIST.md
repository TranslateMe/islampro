# QiblaFinder - Comprehensive Testing Checklist

## Testing Overview

This checklist ensures every feature works correctly before App Store submission. Test systematically and check off items as you complete them.

**Testing Timeline:** 2-3 hours for complete testing
**Recommended:** Test on 2-3 different devices if possible

---

## Quick Pre-Testing Setup

### Test Devices Needed
- [ ] **Primary:** Your main iPhone (daily driver)
- [ ] **Optional:** Second device (different size/model)
- [ ] **Simulator:** Xcode Simulator (for quick checks)

### Preparation
- [ ] Charge devices to 100% (for battery testing)
- [ ] Enable "Location Services" in Settings
- [ ] Have Wi-Fi and cellular data available
- [ ] Clear previous test data:
  ```swift
  // Run in Xcode console or add temporary button:
  UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
  ```
- [ ] Note your current location for testing

---

## 1. First Launch & Onboarding

### 1.1 Fresh Install Experience
- [ ] Delete app if already installed
- [ ] Build and run from Xcode (⌘R)
- [ ] App launches without crashes
- [ ] Launch screen shows (black background)
- [ ] Onboarding appears automatically

### 1.2 Onboarding Flow - Page 1 (Qibla Feature)
- [ ] Page 1 shows "Find Qibla Instantly" title
- [ ] Gold compass icon displays correctly
- [ ] Description text is readable and accurate
- [ ] 3 green checkmarked features display
- [ ] "Skip" button appears in top-right
- [ ] "Swipe to continue" hint shows at bottom
- [ ] Page indicator dots show (page 1 of 3)

### 1.3 Onboarding Flow - Page 2 (Prayer Times)
- [ ] Swipe left transitions smoothly to page 2
- [ ] Page 2 shows "Never Miss Prayer" title
- [ ] Gold clock icon displays correctly
- [ ] Description text is accurate
- [ ] 3 green checkmarked features display
- [ ] "Skip" button still visible
- [ ] Page indicator shows page 2 of 3

### 1.4 Onboarding Flow - Page 3 (Location Permission)
- [ ] Swipe left transitions to page 3
- [ ] Page 3 shows "Location Required" title
- [ ] Gold location icon displays correctly
- [ ] Description explains why location is needed
- [ ] 3 privacy-focused features display
- [ ] "Skip" button is HIDDEN (last page)
- [ ] "Get Started" button shows (gold background)
- [ ] Page indicator shows page 3 of 3

### 1.5 Skip Functionality
- [ ] Delete app and reinstall
- [ ] Launch app, tap "Skip" on page 1
- [ ] Onboarding dismisses immediately
- [ ] App opens to main TabView (Qibla tab active)
- [ ] Location permission alert appears
- [ ] App functions normally after skip

### 1.6 Complete Onboarding Flow
- [ ] Delete app and reinstall
- [ ] Swipe through all 3 pages
- [ ] Tap "Get Started" on page 3
- [ ] Onboarding dismisses
- [ ] Location permission alert appears
- [ ] Tap "Allow While Using App"
- [ ] App opens to Qibla compass
- [ ] Onboarding does NOT reappear on next launch

### 1.7 Onboarding Persistence
- [ ] Kill app (swipe up in app switcher)
- [ ] Relaunch app
- [ ] Onboarding does NOT show again
- [ ] App opens directly to Qibla tab
- [ ] Verify UserDefaults saved: `hasSeenOnboarding = true`

---

## 2. Compass Feature (Qibla Direction)

### 2.1 Initial Load
- [ ] Compass view loads immediately (no lag)
- [ ] Black background displays
- [ ] Loading overlay appears while getting location
- [ ] "Finding Qibla direction..." text shows
- [ ] Spinner animates smoothly

### 2.2 Location Permission States

**First Time (Not Determined):**
- [ ] iOS permission alert appears
- [ ] Alert text: "QiblaFinder needs your location to determine the Qibla direction."
- [ ] Tap "Allow While Using App"
- [ ] Loading overlay continues
- [ ] Compass appears within 3-5 seconds

**Denied:**
- [ ] Go to Settings > Privacy > Location Services
- [ ] Turn off location for QiblaFinder
- [ ] Return to app
- [ ] Loading overlay shows
- [ ] "Open Settings" button appears
- [ ] Tap "Open Settings" → Opens iOS Settings
- [ ] Enable location → Return to app
- [ ] Compass loads automatically

**Always Allow:**
- [ ] Test with "Always Allow" permission
- [ ] Compass works identically to "While Using"

### 2.3 Compass Visual Elements
- [ ] Compass ring displays (white circle)
- [ ] Ring has subtle shadow
- [ ] Cardinal markers show (N, E, S, W in white)
- [ ] Markers positioned correctly around ring
- [ ] Kaaba icon in center (gold, SF Symbol)
- [ ] Icon has gold gradient effect
- [ ] Icon rotates smoothly as you rotate device

### 2.4 Compass Rotation & Accuracy
- [ ] Hold device flat (parallel to ground)
- [ ] Rotate 360° slowly
- [ ] Kaaba icon rotates smoothly (no jitter)
- [ ] Cardinal markers stay fixed to screen
- [ ] Compass ring rotates with device
- [ ] North marker points to actual north
- [ ] Kaaba icon points to Qibla direction

### 2.5 Degree Indicator
- [ ] Bearing text shows below compass (e.g., "245°")
- [ ] Degrees update in real-time as you rotate
- [ ] Text color is gold (matches Kaaba)
- [ ] Font size is large (48pt) and readable
- [ ] Numbers use monospaced digits (no width jitter)
- [ ] "Qibla Direction" label shows below degrees
- [ ] Label is smaller (16pt) and white

### 2.6 Distance Display
- [ ] Distance card shows at bottom
- [ ] Displays distance to Mecca (e.g., "Distance to Mecca: 10,234 km")
- [ ] Distance is accurate for your location
- [ ] Card has semi-transparent white background
- [ ] Text is black and readable
- [ ] Card has rounded corners (16pt)

### 2.7 Alignment Detection
- [ ] Point device toward Qibla direction
- [ ] Get within ±5° of exact bearing
- [ ] Green glow appears around Kaaba icon
- [ ] Glow intensifies when perfectly aligned
- [ ] Haptic feedback fires (single success vibration)
- [ ] VoiceOver announces "Aligned with Qibla"
- [ ] Point away → Glow disappears
- [ ] Point back → Glow reappears (no duplicate haptic)

### 2.8 Accuracy Indicator
- [ ] Accuracy dot shows in top-right
- [ ] Hold device flat → Green dot + checkmark
- [ ] Wave device in figure-8 → Yellow dot + exclamation mark
- [ ] Stop calibration → Returns to green within seconds
- [ ] Green = "High Accuracy" label
- [ ] Yellow = "Medium Accuracy" label
- [ ] If red appears = "Calibrate Compass" label

### 2.9 Calibration Prompt (First Time)
- [ ] Delete app and reinstall
- [ ] Complete onboarding
- [ ] Compass loads with low accuracy (yellow/red)
- [ ] Alert appears: "Compass Calibration Needed"
- [ ] Message explains figure-8 motion
- [ ] Tap "OK" → Alert dismisses
- [ ] Perform calibration → Accuracy improves to green
- [ ] Kill and relaunch app
- [ ] No calibration prompt (shown only once)

### 2.10 Performance & Smoothness
- [ ] Compass updates at smooth 60fps (no stuttering)
- [ ] No lag between device rotation and icon rotation
- [ ] No excessive battery drain (check battery settings after 10min)
- [ ] No overheating during extended use
- [ ] Memory usage stays stable (check Xcode debug navigator)

### 2.11 Edge Cases
- [ ] Test in airplane mode → Shows last known location
- [ ] Test indoors → Compass works (may be less accurate)
- [ ] Test near metal objects → Compass may show yellow accuracy
- [ ] Test in car (moving) → Compass updates location smoothly
- [ ] Test at different locations (>50km apart) → Distance updates
- [ ] Lock device → Screen turns off (expected)
- [ ] Unlock device → Compass resumes immediately

---

## 3. Prayer Times Feature

### 3.1 Initial Load
- [ ] Tap "Prayer Times" tab
- [ ] View loads with black background
- [ ] Loading overlay appears briefly
- [ ] Prayer times populate within 2 seconds

### 3.2 Header Section
- [ ] Location displays at top (city name or coordinates)
- [ ] Location is accurate for current position
- [ ] Hijri date displays below location
- [ ] Hijri date is correct (verify with IslamicFinder.org)
- [ ] Date format: "15 Rajab 1446" (example)
- [ ] Both elements are white text on black background

### 3.3 Prayer Times List
- [ ] 6 prayers display: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha
- [ ] Each row shows:
  - Arabic name (20pt semibold, e.g., "الفجر")
  - English name (16pt medium, e.g., "Fajr")
  - Prayer time (16pt medium, monospaced, e.g., "5:24 AM")
- [ ] All times are accurate for your location
- [ ] Times match IslamicFinder.org (Muslim World League method)

### 3.4 Current Prayer Highlighting
- [ ] Prayer currently happening has GOLD left border (4pt thick)
- [ ] Example: If 2:30 PM, Dhuhr has gold border
- [ ] Border is full height of row

### 3.5 Next Prayer Highlighting
- [ ] Next upcoming prayer has GREEN background (subtle)
- [ ] Green color: `Constants.PRIMARY_GREEN` at 10% opacity
- [ ] Countdown shows: "in 2h 15m" (example)
- [ ] Countdown updates every second
- [ ] Countdown format changes:
  - "in 3h 45m" (hours + minutes)
  - "in 45m" (under 1 hour)
  - "in 5m" (under 10 minutes)
  - "Now" (prayer time arrived)

### 3.6 Passed Prayer Styling
- [ ] Prayers that already passed show at 50% opacity
- [ ] Example: If 2 PM, Fajr and Sunrise are faded
- [ ] Fading is consistent across all passed prayers

### 3.7 Real-Time Countdown
- [ ] Watch countdown for 60 seconds
- [ ] Countdown decrements every second (smooth)
- [ ] "in 10m" → "in 9m" after 60 seconds
- [ ] No freezing or lag
- [ ] Countdown stays accurate

### 3.8 Prayer Time Transitions
- [ ] Wait for a prayer time to arrive (or change device time)
- [ ] When prayer time hits:
  - Current prayer border becomes gold
  - Next prayer background becomes green
  - Previous prayer fades to 50%
  - Countdown resets to next prayer
- [ ] Transitions happen smoothly (no flashing)

### 3.9 Location Updates
- [ ] Note prayer times at current location
- [ ] Travel >50km (or simulate with location spoofing)
- [ ] Return to Prayer Times tab
- [ ] Times recalculate for new location
- [ ] Hijri date stays same (it's a date, not location-based)
- [ ] Location name updates

### 3.10 Calculation Method (Settings Integration)
- [ ] Go to Settings tab
- [ ] Change "Calculation Method" to "ISNA (North America)"
- [ ] Return to Prayer Times tab
- [ ] Times update to reflect new method
- [ ] Verify times changed (Fajr especially sensitive)

### 3.11 Madhab Setting (Settings Integration)
- [ ] Go to Settings tab
- [ ] Change Madhab from Shafi to Hanafi
- [ ] Return to Prayer Times tab
- [ ] Asr time updates (shifts later for Hanafi)
- [ ] Other times unchanged

### 3.12 Background/Foreground Behavior
- [ ] Note current countdown (e.g., "in 2h 15m")
- [ ] Background app (home button or swipe up)
- [ ] Wait 5 minutes
- [ ] Return to app
- [ ] Countdown updated correctly (now "in 2h 10m")
- [ ] No stale data

### 3.13 View Lifecycle
- [ ] Switch to Compass tab
- [ ] Wait 60 seconds
- [ ] Switch back to Prayer Times
- [ ] Countdown is current (timer kept running)
- [ ] No refresh needed

### 3.14 Edge Cases
- [ ] Test in airplane mode → Uses last known location
- [ ] Test at 11:59 PM → Prayer times for next day
- [ ] Test at prayer time boundary → Smooth transition
- [ ] Test with location denied → Shows placeholder or error
- [ ] Kill app during prayer time → Reopens with correct highlighting

### 3.15 Performance
- [ ] Scroll through prayers (smooth scrolling)
- [ ] No lag when switching tabs
- [ ] Timer updates don't cause UI jank
- [ ] Memory usage stable over 10 minutes

---

## 4. Map Feature

### 4.1 Initial Load
- [ ] Tap "Map" tab
- [ ] MapKit loads within 2 seconds
- [ ] Black background during load
- [ ] Map tiles render completely

### 4.2 Map Elements
- [ ] User location shows as blue dot (iOS default)
- [ ] Mecca location shows as gold circle (40pt)
- [ ] Kaaba icon inside Mecca marker (black)
- [ ] Green geodesic line connects both points
- [ ] Line is 3pt thick
- [ ] Line follows great circle route (curved on globe)

### 4.3 Camera Position
- [ ] Both user location and Mecca are visible on screen
- [ ] Camera is centered between the two points
- [ ] Zoom level shows both locations comfortably
- [ ] 1.5x padding around bounding box (not cramped)

### 4.4 Map Interaction
- [ ] Pinch to zoom in → Map zooms smoothly
- [ ] Pinch to zoom out → Map zooms smoothly
- [ ] Drag to pan → Map pans freely
- [ ] Tap Mecca marker → Annotation shows "Mecca"
- [ ] Tap user location → Shows "My Location"
- [ ] Rotate gesture → Map rotates (optional, test if enabled)

### 4.5 Distance Overlay
- [ ] Distance banner shows at bottom or top
- [ ] Format: "10,234 km to Mecca" (example)
- [ ] Distance matches Compass tab distance
- [ ] Distance updates if location changes

### 4.6 Map Style
- [ ] Map uses standard style with realistic elevation
- [ ] Terrain visible (mountains, etc.)
- [ ] Labels readable (city names)
- [ ] Satellite imagery loads (if in realistic mode)

### 4.7 Location Updates
- [ ] Move to new location (or simulate)
- [ ] Blue dot updates position
- [ ] Green line redraws from new position
- [ ] Camera re-centers to show both points
- [ ] Distance updates

### 4.8 Edge Cases
- [ ] Test in airplane mode → Shows last known location
- [ ] Test with location denied → Shows placeholder or error message
- [ ] Test at extreme distances (New Zealand to Mecca) → Line wraps correctly
- [ ] Test very close to Mecca (<100km) → Map still shows both points
- [ ] Rotate device → Map adjusts to new orientation

### 4.9 Performance
- [ ] Map renders without lag
- [ ] Zooming is smooth (60fps)
- [ ] No tile loading delays
- [ ] Memory usage acceptable (check Xcode)
- [ ] No crashes during interaction

---

## 5. Settings Feature

### 5.1 Settings UI
- [ ] Tap "Settings" tab
- [ ] Navigation bar shows "Settings" title
- [ ] Black background throughout
- [ ] Scrollable content (4 sections)

### 5.2 Prayer Settings Section
- [ ] "Prayer Settings" header shows in gold
- [ ] Calculation Method picker displays
  - [ ] Shows current method (e.g., "Muslim World League")
  - [ ] Tap picker → Menu shows 11 methods
  - [ ] Select different method → Updates immediately
  - [ ] Description updates below picker
  - [ ] Setting persists after app restart
- [ ] Madhab picker displays
  - [ ] Shows segmented control (Shafi / Hanafi)
  - [ ] Tap Hanafi → Switches immediately
  - [ ] Description updates below
  - [ ] Setting persists after app restart

### 5.3 Premium Features Section
- [ ] "Premium Features" header shows with lock icon (if not premium)
- [ ] Theme picker displays
  - [ ] Shows current theme (e.g., "Classic (Black & Gold)")
  - [ ] Lock icon shows if not premium
  - [ ] Picker disabled with 50% opacity if not premium
  - [ ] If premium: Tap picker → Shows 4 themes
  - [ ] If premium: Selecting theme updates UI (future feature)
- [ ] Notifications toggle displays
  - [ ] Lock icon shows if not premium
  - [ ] Toggle disabled with 50% opacity if not premium
  - [ ] If premium: Toggle works
  - [ ] If premium: Stepper shows when enabled (5-60 minutes)

### 5.4 Premium Section (Not Premium)
- [ ] "Upgrade to Premium" header shows in gold
- [ ] Feature list displays with gold icons:
  - [ ] Bell icon - "Prayer notifications"
  - [ ] Palette icon - "Custom themes"
  - [ ] Globe icon - "All calculation methods"
  - [ ] Watch icon - "Apple Watch app"
  - [ ] Grid icon - "Home screen widgets"
- [ ] "Upgrade to Premium" button shows
  - [ ] Gold background
  - [ ] Black text
  - [ ] Price "$2.99" on right side
- [ ] "One-time purchase • Lifetime access" text shows
- [ ] "Restore Purchases" button shows (green text)

### 5.5 Premium Section (Premium Active)
- [ ] "Premium Active" header shows in gold
- [ ] Gold checkmark seal icon displays (60pt)
- [ ] "Thank you for supporting QiblaFinder!" message
- [ ] "All premium features unlocked" subtext
- [ ] No upgrade button (replaced with gratitude)

### 5.6 About Section
- [ ] "About" header shows in gold
- [ ] "QiblaFinder" app name displays
- [ ] "Version 1.0.0" shows
- [ ] Description text readable and accurate
- [ ] Text centered in card with rounded background

### 5.7 Settings Persistence
- [ ] Change calculation method to "ISNA"
- [ ] Change madhab to "Hanafi"
- [ ] Kill app completely
- [ ] Relaunch app
- [ ] Go to Settings
- [ ] Both settings retained correctly
- [ ] Prayer times reflect these settings

---

## 6. Premium Purchase Flow (StoreKit)

### 6.1 Pre-Purchase State
- [ ] Open app fresh (not premium)
- [ ] Go to Settings
- [ ] Premium features show lock icons
- [ ] Theme picker disabled
- [ ] Notifications toggle disabled
- [ ] "Upgrade to Premium" section shows

### 6.2 StoreKit Configuration (Testing Setup)
- [ ] In Xcode: Product > Scheme > Edit Scheme
- [ ] Options tab > StoreKit Configuration > "QiblaFinder.storekit" selected
- [ ] Build and run (⌘R)
- [ ] StoreKit sandbox ready

### 6.3 Purchase Button
- [ ] Tap "Upgrade to Premium" button
- [ ] Loading overlay appears immediately
- [ ] Gold spinner displays
- [ ] "Processing purchase..." text shows
- [ ] UI disabled (can't tap other elements)

### 6.4 StoreKit Purchase Sheet
- [ ] StoreKit sandbox sheet appears
- [ ] Product name: "QiblaFinder Premium"
- [ ] Price: "$2.99"
- [ ] "Subscribe" button shows (sandbox wording)
- [ ] Sheet shows over loading overlay

### 6.5 Successful Purchase
- [ ] Tap "Subscribe" in sandbox sheet
- [ ] Sheet dismisses
- [ ] Loading overlay continues briefly
- [ ] Loading overlay dismisses
- [ ] Premium section updates to "Premium Active"
- [ ] Checkmark seal appears
- [ ] "Thank you" message shows
- [ ] Lock icons disappear from premium features
- [ ] Theme picker becomes enabled
- [ ] Notifications toggle becomes enabled

### 6.6 Purchase Persistence
- [ ] Verify premium active
- [ ] Kill app
- [ ] Relaunch app
- [ ] Go to Settings
- [ ] Premium still active (no re-purchase needed)
- [ ] Theme picker still enabled

### 6.7 Purchase Cancellation
- [ ] Reset premium: Settings > Developer > Clear All (or UserDefaults reset)
- [ ] Relaunch app
- [ ] Go to Settings > Tap "Upgrade to Premium"
- [ ] StoreKit sheet appears
- [ ] Tap "Cancel" or X button
- [ ] Sheet dismisses
- [ ] Loading overlay dismisses
- [ ] No error alert (cancellation is normal)
- [ ] Still not premium (expected)

### 6.8 Restore Purchases
- [ ] With premium active, note current state
- [ ] Reset app (delete and reinstall)
- [ ] Complete onboarding
- [ ] Go to Settings (should show not premium)
- [ ] Tap "Restore Purchases" button
- [ ] Loading overlay appears
- [ ] StoreKit verifies previous purchase
- [ ] Loading dismisses
- [ ] Premium unlocks automatically
- [ ] "Thank you" message appears
- [ ] All premium features unlock

### 6.9 Network Errors (Simulated)
- [ ] Enable airplane mode
- [ ] Tap "Upgrade to Premium"
- [ ] Loading appears
- [ ] Wait 10-15 seconds
- [ ] Error alert appears: "Failed to load premium product"
- [ ] Tap "OK" → Alert dismisses
- [ ] App still functional (graceful degradation)
- [ ] Disable airplane mode
- [ ] Retry purchase → Should work

### 6.10 Premium Features Access
- [ ] Unlock premium
- [ ] Try to change theme → Picker is enabled
- [ ] Try to enable notifications → Toggle works
- [ ] Stepper appears for notification timing
- [ ] Set notification to 15 minutes before → Saves correctly
- [ ] Lock and unlock device → Premium persists

---

## 7. Accessibility Testing

### 7.1 VoiceOver (Screen Reader)
- [ ] Enable VoiceOver: Settings > Accessibility > VoiceOver
- [ ] Launch app
- [ ] Swipe through onboarding
  - [ ] Each page title is announced
  - [ ] Feature bullets are announced
  - [ ] Buttons are identified ("Skip button", "Get Started button")
- [ ] Navigate Compass tab
  - [ ] "Qibla direction" is announced
  - [ ] Degree value is announced ("245 degrees")
  - [ ] Alignment announcement: "Aligned with Qibla"
  - [ ] Accuracy status announced
- [ ] Navigate Prayer Times
  - [ ] Each prayer name announced
  - [ ] Prayer times announced
  - [ ] Countdown announced
  - [ ] "Next prayer" status announced
- [ ] Navigate Settings
  - [ ] Pickers are labeled
  - [ ] Toggle states announced ("On" / "Off")
  - [ ] Buttons identified clearly

### 7.2 Dynamic Type (Text Sizing)
- [ ] Go to Settings > Accessibility > Display & Text Size > Larger Text
- [ ] Increase text size to maximum
- [ ] Return to app
- [ ] Check all screens:
  - [ ] Compass: Degree text scales appropriately
  - [ ] Prayer Times: Prayer names and times remain readable
  - [ ] Settings: All text visible and not cut off
  - [ ] Onboarding: All text scales properly
- [ ] Reduce text size to minimum
- [ ] Verify all text still readable

### 7.3 Color Contrast
- [ ] Enable High Contrast: Settings > Accessibility > Display > Increase Contrast
- [ ] Check all screens for readability
  - [ ] White text on black background remains clear
  - [ ] Gold colors remain visible
  - [ ] Green alignment indicator is clear
- [ ] Disable and verify normal contrast works

### 7.4 Reduce Motion
- [ ] Enable Reduce Motion: Settings > Accessibility > Motion > Reduce Motion
- [ ] Launch app
- [ ] Check animations:
  - [ ] Compass still rotates (essential function)
  - [ ] Transitions are less animated (onboarding swipes)
  - [ ] Alignment glow still visible but less animated

---

## 8. Device Compatibility Testing

### 8.1 iPhone Models (Test 2-3 if possible)

**iPhone SE (2nd/3rd gen) - 4.7" display:**
- [ ] All text readable (not too small)
- [ ] Compass fits on screen
- [ ] Prayer times list fits properly
- [ ] Map view displays both points
- [ ] Settings scrollable without cutting off

**iPhone 14/15 - 6.1" display:**
- [ ] Standard experience
- [ ] All elements properly sized
- [ ] No excessive white space

**iPhone 14/15 Pro Max - 6.7" display:**
- [ ] Large screen utilization good
- [ ] Text not too small
- [ ] Compass scales nicely
- [ ] Dynamic Island doesn't interfere

### 8.2 iOS Version Compatibility
- [ ] Test on iOS 17.0 (minimum supported)
- [ ] Test on latest iOS 17.x
- [ ] Test on iOS 18.x if available
- [ ] Verify all features work on each version

### 8.3 Device Orientations
- [ ] Portrait mode (default)
  - [ ] All tabs function correctly
  - [ ] All elements visible
- [ ] Landscape mode
  - [ ] App rotates (if orientation allowed)
  - [ ] Or stays portrait-locked (if configured)
  - [ ] Test Info.plist settings match design intent

---

## 9. Performance & Battery Testing

### 9.1 Battery Drain
- [ ] Charge device to 100%
- [ ] Note battery percentage
- [ ] Open app on Compass tab
- [ ] Use for 30 minutes (actively checking direction)
- [ ] Note final battery percentage
- [ ] Drain should be < 10% (expected for GPS + compass)
- [ ] Check Settings > Battery for app usage

### 9.2 Memory Usage
- [ ] Open Xcode > Debug Navigator > Memory
- [ ] Run app
- [ ] Navigate through all tabs 10 times
- [ ] Memory usage should:
  - [ ] Stay under 100MB typical
  - [ ] Not continuously increase (no memory leaks)
  - [ ] Return to baseline after navigation

### 9.3 CPU Usage
- [ ] Open Xcode > Debug Navigator > CPU
- [ ] Compass tab active
- [ ] CPU should:
  - [ ] Average < 20% during idle
  - [ ] Spike briefly during rotation
  - [ ] Return to low % when stationary
- [ ] Prayer Times tab
  - [ ] CPU < 10% (timer updates)

### 9.4 Network Usage
- [ ] Monitor network activity (Xcode Debug Navigator)
- [ ] StoreKit purchase:
  - [ ] Brief network activity during purchase
  - [ ] No continuous polling
- [ ] Location services:
  - [ ] Uses GPS, not network (mostly)
  - [ ] Minimal data usage

---

## 10. Edge Cases & Error Scenarios

### 10.1 No Internet Connection
- [ ] Enable airplane mode
- [ ] Launch app
- [ ] Compass works (uses GPS only)
- [ ] Prayer times work (calculation is local)
- [ ] Map loads cached tiles (or shows blank)
- [ ] Premium purchase fails gracefully
- [ ] No app crashes

### 10.2 Location Services Disabled (System-Wide)
- [ ] Settings > Privacy > Location Services > OFF
- [ ] Launch app
- [ ] Permission alert cannot appear
- [ ] Loading overlay shows indefinitely OR
- [ ] Error message: "Location Services disabled"
- [ ] App doesn't crash

### 10.3 Background/Foreground Cycles
- [ ] Open app on Compass tab
- [ ] Background app (home button)
- [ ] Wait 5 minutes
- [ ] Foreground app
- [ ] Compass resumes immediately
- [ ] Location still updating
- [ ] Background Prayer Times tab
- [ ] Foreground app
- [ ] Prayer times timer still running

### 10.4 Low Battery Mode
- [ ] Enable Low Battery Mode
- [ ] Open app
- [ ] All features work
- [ ] Location updates may be less frequent (iOS behavior)
- [ ] App adapts gracefully

### 10.5 Date/Time Edge Cases
- [ ] Test at midnight (11:59 PM → 12:00 AM)
  - [ ] Prayer times transition to next day
  - [ ] Hijri date increments
- [ ] Test at prayer time boundary (e.g., 5:24 AM)
  - [ ] Current/next highlighting updates
  - [ ] Countdown resets
- [ ] Test changing device time manually
  - [ ] App uses device time correctly
  - [ ] Prayer times calculate for current time

### 10.6 Extreme Locations
- [ ] Test near North/South Pole (if possible via spoofing)
  - [ ] Qibla calculation still works
  - [ ] Prayer times may be adjusted (Islamic guidelines)
- [ ] Test exactly in Mecca
  - [ ] Distance shows "0 km"
  - [ ] Qibla direction shows Kaaba location
- [ ] Test on international date line
  - [ ] Date calculations correct

### 10.7 Rapid Tab Switching
- [ ] Rapidly tap between all 4 tabs (10 times quickly)
- [ ] No crashes
- [ ] No UI freezing
- [ ] Each tab loads correctly
- [ ] No memory leaks

---

## 11. Build & Deployment Testing

### 11.1 Debug Build
- [ ] Build in Xcode (⌘B)
- [ ] No compilation errors
- [ ] No warnings (or only acceptable warnings)
- [ ] Build succeeds in < 30 seconds

### 11.2 Release Build
- [ ] Change scheme to "Release"
- [ ] Build (⌘B)
- [ ] Build succeeds
- [ ] Install on device
- [ ] App runs identically to debug
- [ ] Performance slightly better (optimizations)

### 11.3 Archive & Export
- [ ] Product > Archive
- [ ] Archive succeeds
- [ ] Xcode Organizer shows archive
- [ ] Export for Ad Hoc distribution
- [ ] Install exported .ipa on device
- [ ] App launches and functions correctly

### 11.4 TestFlight Preparation
- [ ] Archive created successfully
- [ ] Increment build number (e.g., 1 → 2)
- [ ] Re-archive
- [ ] Export for App Store distribution
- [ ] Ready to upload (don't upload yet without icon)

---

## 12. Final Pre-Submission Checks

### 12.1 App Store Requirements
- [ ] App icon present (1024×1024 PNG)
- [ ] Launch screen configured and working
- [ ] All features functional
- [ ] No crashes in any scenario tested
- [ ] Premium purchase works (tested with sandbox)
- [ ] Restore purchases works
- [ ] Location permission descriptions clear and accurate
- [ ] Privacy policy URL ready (if collecting data)

### 12.2 Metadata Preparation
- [ ] App name decided (max 30 characters)
- [ ] Subtitle decided (max 30 characters)
- [ ] Keywords selected (max 100 characters)
- [ ] App description written (max 4000 characters)
- [ ] Screenshots captured (5 required sizes)
- [ ] Promotional text written (optional, 170 characters)

### 12.3 Legal & Compliance
- [ ] Privacy policy created (required for IAP)
- [ ] Terms of service (optional but recommended)
- [ ] Age rating questionnaire completed
- [ ] Content rights verified (all icons/images are legal)
- [ ] No copyrighted material without permission

### 12.4 App Review Preparation
- [ ] Demo account created (if login required - N/A for this app)
- [ ] Special instructions for reviewer written
- [ ] Contact information correct
- [ ] Support URL active

---

## 13. Common Issues & Fixes

### Issue: Compass doesn't rotate
**Fix:**
- Check device has compass hardware
- Grant location permission
- Calibrate compass (figure-8 motion)
- Restart app

### Issue: Prayer times incorrect
**Fix:**
- Verify location is accurate
- Check calculation method in Settings
- Compare with IslamicFinder.org
- Try different calculation method

### Issue: Premium doesn't unlock after purchase
**Fix:**
- Kill and relaunch app
- Tap "Restore Purchases"
- Check StoreKit configuration in Xcode
- Verify `isPremium` in UserDefaults

### Issue: Map doesn't load
**Fix:**
- Check internet connection
- Verify location permission granted
- Wait longer (tiles may be loading)
- Restart app

### Issue: App crashes on launch
**Fix:**
- Check Xcode console for error
- Verify all required permissions in Info.plist
- Clean build folder (⌘⇧K)
- Delete derived data

### Issue: Location permission not requested
**Fix:**
- Verify `NSLocationWhenInUseUsageDescription` in Info.plist
- Call `LocationManager.shared.startUpdatingLocation()`
- Check if permission already denied (Settings > App)

---

## 14. Testing Sign-Off

### Testing Completion
- [ ] All checklist items completed
- [ ] No critical bugs found
- [ ] All features working as expected
- [ ] App ready for App Store submission

### Tester Information
**Tested by:** ___________________
**Date:** ___________________
**Devices used:** ___________________
**iOS versions tested:** ___________________

### Notes
Any issues found during testing:

```
[Add any bugs, edge cases, or improvements noted during testing]
```

---

## Next Steps After Testing

1. ✅ **Fix any bugs found** - Address all critical issues
2. ✅ **Get app icon** - Commission or create 1024×1024 PNG
3. ✅ **Capture screenshots** - 5 required sizes for App Store
4. ✅ **Write app description** - Use templates in APP_STORE_GUIDE.md
5. ✅ **Create privacy policy** - Required for IAP apps
6. ✅ **Submit to App Store** - Follow APP_STORE_GUIDE.md

---

## Testing Tools Used

- **Xcode Simulator** - Quick testing and development
- **Physical Devices** - Real-world testing (recommended)
- **Xcode Instruments** - Performance profiling
- **Debug Navigator** - Memory/CPU monitoring
- **StoreKit Testing** - IAP sandbox testing
- **Accessibility Inspector** - VoiceOver testing

---

**Estimated Testing Time:** 2-3 hours for comprehensive testing
**Recommended:** Test on 2-3 different device sizes
**Critical:** Test StoreKit purchase flow thoroughly

Good luck with testing! 🚀
