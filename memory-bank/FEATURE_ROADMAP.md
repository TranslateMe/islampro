# QiblaFinder - Feature Roadmap (v1.1 - v1.4)

**Document Version:** 1.0
**Last Updated:** October 16, 2025
**Planning Horizon:** 6 months post-launch

---

## Overview

This document outlines the planned feature development roadmap for QiblaFinder following the successful v1.0 launch. Features are organized by version milestone with estimated development times, technical requirements, and implementation notes.

**Guiding Principles:**
- **User Value First:** Every feature must solve a real user need
- **Quality Over Quantity:** Deep polish on few features beats many shallow ones
- **Performance Conscious:** Maintain 60fps and low battery usage
- **Privacy Focused:** No data collection, no tracking
- **Accessibility:** VoiceOver support for all new features

---

## Version 1.1 - Competitive Feature Parity

**Release Target:** 2-3 weeks after v1.0 launch
**Focus:** Essential features users expect from prayer apps
**Development Time:** 11-15 hours
**Priority:** HIGH

### Goals
- Match feature set of top Islamic apps
- Improve user retention (7-day retention target: 50%+)
- Increase daily active usage
- Collect user feedback for v1.2 planning

---

### Feature 1.1.1: Adhan Audio Playback

**User Story:** As a user, I want to hear the adhan (call to prayer) when prayer time arrives, so I'm reminded audibly.

**Requirements:**
- Bundle 3-5 professional reciters (different voices/styles)
- Play adhan automatically at prayer time (if notifications enabled)
- Allow user to select reciter in settings
- Volume controls (system volume + optional adjustment)
- Fade-in effect (3-5 seconds)
- Stop button in notification
- Works with device on silent mode (optional override)

**Technical Implementation:**
- Use AVAudioPlayer for playback
- Bundle .mp3 or .m4a files (compressed, high quality)
- File size: ~1-2MB per adhan (total ~5-10MB app increase)
- Background audio capability (Info.plist)
- Integrate with NotificationManager
- Add UNNotificationAction for "Stop Adhan"

**Files to Create:**
- `Services/AdhanAudioManager.swift`
- `Resources/Adhan/reciter1.m4a`
- `Resources/Adhan/reciter2.m4a`
- `Resources/Adhan/reciter3.m4a`
- `Views/Settings/AdhanSettingsView.swift` (settings section)

**Settings UI:**
```swift
Section("Adhan Audio") {
    if isPremium {
        Toggle("Play Adhan", isOn: $playAdhan)

        if playAdhan {
            Picker("Reciter", selection: $selectedReciter) {
                ForEach(Reciter.allCases) { reciter in
                    Text(reciter.displayName)
                        .tag(reciter)
                }
            }

            HStack {
                Text("Volume")
                Slider(value: $adhanVolume, in: 0.3...1.0)
            }

            Toggle("Override Silent Mode", isOn: $overrideSilent)
                .font(.caption)
        }
    } else {
        // Premium gate
    }
}
```

**Testing:**
- Test at actual prayer time (wait or change device time)
- Test with device locked
- Test with app in background
- Test stop button in notification
- Test different reciters
- Test volume levels
- Test silent mode override

**Estimated Time:** 6-8 hours

---

### Feature 1.1.2: Tasbih Counter - Tap Mode

**User Story:** As a user, I want to count my dhikr (remembrance) using a digital counter, so I don't need physical beads.

**Requirements:**
- Simple tap-to-increment counter
- Large tap area (entire screen)
- Display current count (large, clear number)
- Goal presets (33, 99, 100, custom)
- Haptic feedback on each tap
- Celebration animation on goal completion
- Sound effect option (bead click sound)
- Reset button
- History tracking (optional: how many completed today)
- Vibration on goal completion

**Technical Implementation:**
- New tab or modal presentation
- @State for counter value
- UIImpactFeedbackGenerator for haptics
- Custom animation for goal celebration
- UserDefaults for history

**Files to Create:**
- `Views/Tasbih/TasbihView.swift`
- `ViewModels/TasbihViewModel.swift`
- `Resources/Sounds/bead_click.mp3` (optional)

**UI Design:**
```swift
ZStack {
    // Tap area (entire screen)
    Color.clear
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.increment()
        }

    VStack {
        // Count display
        Text("\(viewModel.count)")
            .font(.system(size: 120, weight: .bold, design: .rounded))
            .foregroundColor(themeColor)

        // Goal display
        Text("\(viewModel.goal - viewModel.count) remaining")
            .font(.title3)
            .foregroundColor(.secondary)

        Spacer()

        // Controls
        HStack {
            Button("Reset") { viewModel.reset() }
            Spacer()
            Button("Goal: \(viewModel.goal)") { showGoalPicker = true }
        }
        .padding()
    }

    // Celebration overlay (when goal reached)
    if viewModel.isGoalReached {
        ConfettiView()
            .transition(.scale.combined(with: .opacity))
    }
}
```

**Goal Presets:**
- 33 (SubhanAllah, Alhamdulillah, Allahu Akbar after prayer)
- 99 (99 names of Allah)
- 100 (general dhikr)
- Custom (user-defined)

**Testing:**
- Tap rapidly 100 times, verify no dropped counts
- Test goal completion animation
- Test haptic feedback (feel natural, not excessive)
- Test sound effects
- Test reset functionality
- Test different goal presets
- Test on older devices (performance)

**Estimated Time:** 2-3 hours

---

### Feature 1.1.3: Hijri Calendar Integration

**User Story:** As a user, I want to see the Islamic date alongside the Gregorian date, so I'm aware of important Islamic dates.

**Requirements:**
- Display Hijri date in prayer times header
- Show on main compass view (optional)
- Highlight important Islamic dates:
  - Ramadan
  - Eid al-Fitr, Eid al-Adha
  - Ashura
  - Laylat al-Qadr (estimated)
  - Islamic New Year
- Islamic month names in Arabic + English
- Day, month, year format ("15 Ramadan 1446")
- Support for different Hijri calendar adjustments

**Technical Implementation:**
- Enhance existing HijriDateService
- Add important dates database
- Calculate moon phases (optional)
- Notifications for important dates

**Files to Modify:**
- `Services/HijriDateService.swift` (expand)
- `Views/PrayerTimes/PrayerTimesView.swift` (add Hijri date)
- `Views/Compass/CompassView.swift` (optional display)

**Important Dates Database:**
```swift
enum IslamicDate {
    case ramadan(day: Int)
    case eidAlFitr
    case eidAlAdha
    case ashu

ra
    case laylatAlQadr
    case islamicNewYear
    case mawlid

    var description: String { ... }
    var icon: String { ... } // SF Symbol
}

class IslamicCalendarService {
    func getSpecialDate(for date: Date) -> IslamicDate? {
        // Check if date is special
    }
}
```

**UI Enhancement:**
```swift
// In PrayerTimesView header
VStack(alignment: .leading) {
    Text(locationName)
        .font(.title2)
        .bold()

    // Hijri date (existing)
    HStack {
        Image(systemName: "moon.circle.fill")
            .foregroundColor(.yellow)
        Text(hijriDate)
            .font(.subheadline)
    }

    // Special date badge (new)
    if let specialDate = viewModel.specialDate {
        HStack {
            Image(systemName: specialDate.icon)
                .foregroundColor(.gold)
            Text(specialDate.description)
                .font(.caption)
                .foregroundColor(.gold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gold.opacity(0.1))
        .cornerRadius(8)
    }

    Text(gregorianDate)
        .font(.caption)
        .foregroundColor(.secondary)
}
```

**Testing:**
- Verify Hijri date accurate (compare with online calculators)
- Test month transitions
- Test year transitions
- Test special date detection
- Test during Ramadan (if possible, or change device time)
- Test in English and Arabic

**Estimated Time:** 3-4 hours

---

### v1.1 Summary

**Total Features:** 3
**Total Development Time:** 11-15 hours
**Release Strategy:**
- Submit to App Store 2 weeks after v1.0 launch
- Request expedited review if critical bug fixes included
- Announce update via social media, email (if list exists)
- Monitor crash reports closely (new audio code)

**Success Metrics:**
- Adhan audio: 40%+ of users enable
- Tasbih counter: 20%+ of users try
- Hijri calendar: Visible to all users
- Overall: 50%+ 7-day retention (up from baseline)
- No increase in crash rate

---

## Version 1.2 - Premium Experience & Differentiation

**Release Target:** Month 2-3 after launch
**Focus:** Features that differentiate from competitors
**Development Time:** 1-2 weeks
**Priority:** MEDIUM

### Goals
- Unique features not available in other apps
- Increase premium conversion rate
- Build Apple ecosystem integration
- Enhance user engagement

---

### Feature 1.2.1: Apple Watch App

**User Story:** As a user, I want to access Qibla direction and prayer times on my Apple Watch, so I don't need to pull out my phone.

**Requirements:**
- **Complications:** Display next prayer time on watch face
  - Circular small: Prayer time
  - Rectangular: Prayer name + time
  - Graphic corner: Prayer name + countdown
- **Watch App Views:**
  1. Qibla compass (uses watch orientation sensors)
  2. Prayer times list
  3. Tasbih counter (digital crown control)
- **WatchConnectivity:** Sync data from iPhone
- **Watch-only mode:** Calculate prayer times on watch (if iPhone unavailable)
- **Notifications:** Prayer reminders on watch
- **Haptic feedback:** Gentle taps for prayer times

**Technical Implementation:**
- Add watchOS target (File > New > Target > Watch App)
- SwiftUI for watchOS (reuse view logic where possible)
- WatchConnectivity framework for data sync
- Complication timeline provider
- Watch location services (independent)

**Files to Create:**
- `QiblaFinderWatch/ContentView.swift`
- `QiblaFinderWatch/CompassView.swift`
- `QiblaFinderWatch/PrayerListView.swift`
- `QiblaFinderWatch/TasbihView.swift`
- `QiblaFinderWatch/ComplicationController.swift`
- `Shared/WatchConnectivityManager.swift`

**Watch Compass View:**
```swift
struct CompassView: View {
    @StateObject private var viewModel = WatchCompassViewModel()

    var body: some View {
        ZStack {
            // Compass ring
            Circle()
                .stroke(Color.green, lineWidth: 4)
                .frame(width: 150, height: 150)

            // Kaaba pointer
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.gold)
                .rotationEffect(.degrees(viewModel.qiblaAngle))

            // Degree indicator
            Text("\(Int(viewModel.qiblaBearing))°")
                .font(.caption2)
                .offset(y: -80)
        }
        .digitalCrownRotation($viewModel.manualAdjustment)
    }
}
```

**Complications:**
```swift
struct ComplicationTimelineProvider: ComplicationDataSource {
    func getComplicationData(...) {
        let nextPrayer = viewModel.nextPrayer

        switch complication.family {
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: nextPrayer.formattedTime)
            )

        case .graphicCorner:
            return CLKComplicationTemplateGraphicCornerTextImage(
                textProvider: CLKSimpleTextProvider(text: "\(nextPrayer.name) \(nextPrayer.countdown)"),
                imageProvider: CLKFullColorImageProvider(fullColorImage: prayerIcon)
            )

        // ... other families
        }
    }
}
```

**WatchConnectivity Sync:**
```swift
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    // iPhone sends prayer times to watch
    func sendPrayerTimes(_ prayers: [Prayer]) {
        let data = try? JSONEncoder().encode(prayers)
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["prayers": data], replyHandler: nil)
        } else {
            // Transfer to watch when available
            WCSession.default.transferUserInfo(["prayers": data])
        }
    }

    // Watch receives prayer times
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let data = message["prayers"] as? Data else { return }
        let prayers = try? JSONDecoder().decode([Prayer].self, from: data)
        // Update watch UI
    }
}
```

**Testing:**
- Pair Apple Watch with iPhone
- Install watch app, verify appears
- Add complications to watch face, verify display
- Test compass on watch (rotate wrist)
- Test prayer times list
- Test sync between iPhone and watch
- Test watch-only mode (iPhone out of range)
- Test battery impact (important for watch)
- Test different watch models (Series 4+)

**Estimated Time:** 2-3 days (16-24 hours)

**Considerations:**
- Watch app significantly increases complexity
- May defer if time-constrained
- High user value for Apple Watch owners (~30% of iOS users)

---

### Feature 1.2.2: Duas Collection

**User Story:** As a user, I want to access common daily duas (supplications) in the app, so I can recite them properly.

**Requirements:**
- Curated collection of essential duas:
  - Morning duas (after Fajr)
  - Evening duas (after Maghrib)
  - After-prayer duas (post-salah)
  - Before sleep
  - Before eating
  - Traveling duas
  - General protection
- Each dua includes:
  - Arabic text (large, readable font)
  - Transliteration (Latin script)
  - English translation
  - Reference (Quran/Hadith)
  - Audio recitation (optional, v1.3)
- Search functionality
- Favorite/bookmark system
- Category organization

**Technical Implementation:**
- JSON database of duas
- Bundle with app or fetch remotely
- Core Data for favorites (persistent)
- SwiftUI List for browsing

**Files to Create:**
- `Models/Dua.swift`
- `Services/DuaManager.swift`
- `Views/Duas/DuaListView.swift`
- `Views/Duas/DuaDetailView.swift`
- `Resources/Duas/duas.json`

**Dua Model:**
```swift
struct Dua: Identifiable, Codable {
    let id: UUID
    let category: DuaCategory
    let arabicText: String
    let transliteration: String
    let translation: String
    let reference: String // "Quran 2:286"
    var isFavorite: Bool = false

    enum DuaCategory: String, Codable {
        case morning, evening, afterPrayer, sleep, eating, traveling, protection, general
    }
}
```

**List View:**
```swift
struct DuaListView: View {
    @StateObject private var viewModel = DuaViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(DuaCategory.allCases, id: \.self) { category in
                    Section(category.displayName) {
                        ForEach(viewModel.duas(in: category)) { dua in
                            NavigationLink(destination: DuaDetailView(dua: dua)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(dua.arabicText.prefix(50))
                                            .font(.body)
                                            .lineLimit(1)
                                        Text(dua.transliteration.prefix(50))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if dua.isFavorite {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.gold)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Duas")
        }
    }
}
```

**Detail View:**
```swift
struct DuaDetailView: View {
    let dua: Dua
    @State private var fontSize: Double = 20

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Arabic text (right-aligned)
                Text(dua.arabicText)
                    .font(.custom("Arabic Font", size: fontSize))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Divider()

                // Transliteration
                Text(dua.transliteration)
                    .font(.system(size: fontSize * 0.8, design: .serif))
                    .italic()
                    .foregroundColor(.secondary)

                // Translation
                Text(dua.translation)
                    .font(.system(size: fontSize * 0.9))

                // Reference
                Text(dua.reference)
                    .font(.caption)
                    .foregroundColor(.green)

                // Font size slider
                HStack {
                    Text("A")
                        .font(.caption)
                    Slider(value: $fontSize, in: 14...32)
                    Text("A")
                        .font(.title)
                }
            }
            .padding()
        }
        .navigationTitle("Dua")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                // Toggle favorite
            } label: {
                Image(systemName: dua.isFavorite ? "star.fill" : "star")
            }
        }
    }
}
```

**Duas JSON Database:**
```json
[
  {
    "id": "morning-1",
    "category": "morning",
    "arabicText": "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ...",
    "transliteration": "Asbahna wa asbahal-mulku lillah...",
    "translation": "We have reached the morning and at this very time all sovereignty belongs to Allah...",
    "reference": "Muslim 2723"
  },
  ...
]
```

**Testing:**
- Verify all duas load correctly
- Test search functionality
- Test favorite/unfavorite
- Test font size adjustment
- Test Arabic text rendering
- Test in English and Arabic app language
- Verify references accurate

**Estimated Time:** 1-2 days (8-16 hours)

---

### Feature 1.2.3: Tasbih Voice Mode

**User Story:** As a user, I want to count dhikr using voice recognition, so I can count hands-free while doing other tasks.

**Requirements:**
- Speech recognition for specific phrases
- Supported phrases:
  - "SubhanAllah"
  - "Alhamdulillah"
  - "Allahu Akbar"
  - "La ilaha illallah"
- Real-time phrase detection
- Visual feedback when phrase recognized
- Background noise handling
- Works with headphones/speaker
- Privacy: Speech processing on-device only (no cloud)

**Technical Implementation:**
- Speech framework (on-device recognition)
- SFSpeechRecognizer for Arabic
- Audio session management
- Continuous recognition with phrase detection

**Files to Create:**
- `Services/VoiceRecognitionManager.swift`
- `Views/Tasbih/VoiceModeView.swift`
- `ViewModels/VoiceTasbihViewModel.swift`

**Voice Recognition Manager:**
```swift
import Speech

class VoiceRecognitionManager: ObservableObject {
    @Published var recognizedPhrase: String = ""
    @Published var isListening: Bool = false
    @Published var phraseCount: Int = 0

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startListening() {
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let result = result else { return }

            let transcript = result.bestTranscription.formattedString.lowercased()
            self?.detectPhrase(in: transcript)
        }

        // Start audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
        isListening = true
    }

    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isListening = false
    }

    private func detectPhrase(in transcript: String) {
        let phrases = ["subhanallah", "alhamdulillah", "allahu akbar", "la ilaha illallah"]

        for phrase in phrases {
            if transcript.contains(phrase) {
                phraseCount += 1
                recognizedPhrase = phrase
                HapticFeedback.light()
                // Clear transcript buffer to avoid double-counting
                recognitionRequest?.endAudio()
                recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            }
        }
    }
}
```

**Voice Mode UI:**
```swift
struct VoiceModeView: View {
    @StateObject private var voiceManager = VoiceRecognitionManager()
    @State private var showPermissionAlert = false

    var body: some View {
        ZStack {
            // Background
            themeBackground.ignoresSafeArea()

            VStack(spacing: 40) {
                // Count display
                Text("\(voiceManager.phraseCount)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundColor(themeColor)

                // Last recognized phrase
                Text(voiceManager.recognizedPhrase)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .animation(.easeInOut, value: voiceManager.recognizedPhrase)

                // Listening indicator
                if voiceManager.isListening {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .pulse(isActive: true)

                        Text("Listening...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Start/Stop button
                Button {
                    if voiceManager.isListening {
                        voiceManager.stopListening()
                    } else {
                        Task {
                            let granted = await voiceManager.requestPermission()
                            if granted {
                                voiceManager.startListening()
                            } else {
                                showPermissionAlert = true
                            }
                        }
                    }
                } label: {
                    Image(systemName: voiceManager.isListening ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(voiceManager.isListening ? .red : .green)
                }
            }
        }
        .alert("Microphone Permission Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}
```

**Testing:**
- Request microphone permission
- Say "SubhanAllah" clearly, verify count increments
- Say each supported phrase, verify recognition
- Test in noisy environment (background TV/music)
- Test with headphones vs speaker
- Test Arabic pronunciation variations
- Test language mixing (Arabic + English)
- Verify on-device processing (airplane mode test)

**Estimated Time:** 1-2 days (8-16 hours)

**Considerations:**
- Speech recognition accuracy varies by accent/pronunciation
- May not work well in noisy environments
- On-device recognition (iOS 13+) ensures privacy
- Could be premium feature or free

---

### Feature 1.2.4: Enhanced Themes

**User Story:** As a premium user, I want more theme options and seasonal themes, so I can personalize my app experience.

**Requirements:**
- Additional theme options:
  - **Ocean Depth:** Deep blue with lighter blue accents
  - **Sunset Glow:** Orange/pink gradient
  - **Forest Green:** Rich greens with gold highlights
  - **Royal Purple:** Purple with gold (luxury feel)
  - **Ramadan Special:** Green/gold with crescent moon motifs
- Seasonal auto-switching (optional)
- Community theme sharing (future)
- Theme previews before applying
- Export/import custom themes

**Technical Implementation:**
- Expand Theme enum
- Add theme preview UI
- Persist theme selection
- Dynamic asset loading

**New Themes:**
```swift
enum AppTheme: String, CaseIterable {
    case classic, midnight, forest, desert

    // v1.2 additions
    case oceanDepth, sunsetGlow, forestGreen, royalPurple, ramadanSpecial

    var primaryColor: Color {
        switch self {
        case .oceanDepth: return Color(red: 0.1, green: 0.4, blue: 0.7)
        case .sunsetGlow: return Color(red: 1.0, green: 0.5, blue: 0.3)
        case .forestGreen: return Color(red: 0.2, green: 0.6, blue: 0.3)
        case .royalPurple: return Color(red: 0.5, green: 0.2, blue: 0.7)
        case .ramadanSpecial: return Color(hex: Constants.GOLD_COLOR)
        default: return Color(hex: Constants.PRIMARY_GREEN)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .oceanDepth: return Color(red: 0.05, green: 0.1, blue: 0.2)
        case .sunsetGlow: return Color(red: 0.15, green: 0.1, blue: 0.15)
        case .forestGreen: return Color(red: 0.05, green: 0.15, blue: 0.08)
        case .royalPurple: return Color(red: 0.1, green: 0.05, blue: 0.15)
        case .ramadanSpecial: return Color(red: 0.05, green: 0.2, blue: 0.1)
        default: return .black
        }
    }

    // ... other color properties
}
```

**Theme Preview:**
```swift
struct ThemePreviewView: View {
    let theme: AppTheme

    var body: some View {
        VStack {
            // Compass preview
            ZStack {
                Circle()
                    .stroke(theme.primaryColor, lineWidth: 4)
                    .frame(width: 100, height: 100)

                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(theme.primaryColor)
            }

            // Prayer row preview
            HStack {
                Text("Fajr")
                Spacer()
                Text("5:42 AM")
            }
            .padding()
            .background(theme.secondaryBackgroundColor)
            .cornerRadius(8)

            // Text samples
            Text("Sample Text")
                .foregroundColor(theme.textPrimary)
        }
        .padding()
        .background(theme.backgroundColor)
        .cornerRadius(16)
    }
}
```

**Seasonal Auto-Switching:**
```swift
class ThemeManager: ObservableObject {
    func getSeasonalTheme() -> AppTheme? {
        let calendar = Calendar(identifier: .islamicUmAlQura)
        let month = calendar.component(.month, from: Date())

        // Month 9 = Ramadan
        if month == 9 {
            return .ramadanSpecial
        }

        return nil // No seasonal override
    }
}
```

**Testing:**
- Apply each new theme
- Verify colors visible and readable
- Test in light/dark system mode
- Test compass, prayer times, map with each theme
- Test theme persistence
- Test seasonal switching (change device date)

**Estimated Time:** 4-6 hours

---

### v1.2 Summary

**Total Features:** 4
**Total Development Time:** 1-2 weeks
**Release Strategy:**
- Submit 6-8 weeks after v1.0 launch
- Coordinate with Ramadan if timing aligns (big marketing opportunity)
- Highlight Apple Watch app in marketing
- Create video demo of voice mode

**Success Metrics:**
- Apple Watch app: 15%+ of users with watches install
- Duas: 30%+ of users browse collection
- Voice mode: 10%+ of users try (novelty feature)
- Enhanced themes: 40%+ of users change default theme
- Premium conversion: 25%+ (up from v1.1)

---

## Version 1.3 - Community & Engagement Features

**Release Target:** Month 4-5 after launch
**Focus:** Social features and community building
**Development Time:** 1-2 weeks
**Priority:** MEDIUM-LOW

### Goals
- Build engaged user community
- Encourage daily app usage
- Gamification elements
- Mosque integration

---

### Feature 1.3.1: Mosque Finder

**User Story:** As a user, I want to find nearby mosques with directions, so I can pray in congregation.

**Requirements:**
- Google Places API integration
- Map view with mosque markers
- List view with distance sorting
- Prayer times per mosque (community-provided)
- Directions (Apple Maps integration)
- Photos and reviews
- Save favorites
- Filter by facilities (women's section, parking, etc.)

**Technical Implementation:**
- Google Places API (requires API key + billing)
- MapKit for displaying results
- Core Data for favorites

**Estimated Time:** 3-4 days

---

### Feature 1.3.2: Prayer Tracking & Analytics

**User Story:** As a user, I want to track my prayers and see statistics, so I can improve my consistency.

**Requirements:**
- Mark prayers as completed
- Streak tracking (consecutive days)
- Weekly/monthly statistics
- Visual charts (prayer completion percentage)
- Reminder to mark as prayed
- Privacy: All data stored locally
- Export data

**Technical Implementation:**
- Core Data for prayer history
- Charts framework for visualizations
- UserDefaults for streaks

**Estimated Time:** 2-3 days

---

### Feature 1.3.3: Ramadan Special Mode

**User Story:** As a user, I want special Ramadan features during the holy month, so the app adapts to my needs.

**Requirements:**
- Automatic detection (Hijri calendar month 9)
- Suhoor/Iftar times calculated
- Countdown to Iftar
- Daily reminder for Suhoor
- Special Ramadan theme (green/gold with stars/crescents)
- Taraweeh prayer time
- Daily Quran reading tracker (Juz per day)

**Technical Implementation:**
- Extend prayer calculator for Suhoor/Iftar
- Theme system enhancement
- Notification scheduling

**Estimated Time:** 2 days

---

### v1.3 Summary

**Total Features:** 3
**Total Development Time:** 1-2 weeks
**Release Strategy:**
- Time release for Ramadan if possible (huge engagement boost)
- Partner with mosques for data (community engagement)

---

## Version 1.4 - Advanced Features & Innovation

**Release Target:** Month 6+ after launch
**Focus:** Cutting-edge features that wow users
**Development Time:** 2-3 weeks
**Priority:** LOW (Nice-to-have)

### Feature 1.4.1: AR Qibla Finder
- Point camera at horizon
- AR arrow overlay pointing to Mecca
- Works like AR compass
- ARKit integration
**Estimated Time:** 1-2 weeks

### Feature 1.4.2: Widget Enhancements
- Lock screen widgets (iOS 16+)
- Live Activities (countdown to next prayer)
- Interactive widgets
**Estimated Time:** 3-4 days

### Feature 1.4.3: Siri Shortcuts
- "Hey Siri, where's Qibla?"
- "Hey Siri, when's next prayer?"
- Quick action shortcuts
**Estimated Time:** 2-3 days

---

## Features Intentionally Excluded

### Quran Reader
**Reason:** Separate app scope, requires extensive Islamic scholarship, copyright concerns

### Live Kaaba Feed
**Reason:** Battery drain, internet required, not essential for prayer

### Social Sharing
**Reason:** Privacy concerns, not aligned with app's purpose

### Halal Restaurant Finder
**Reason:** Out of scope, other apps do this well

### Full Voice Assistant
**Reason:** Siri shortcuts sufficient, complex to maintain

---

## Roadmap Flexibility

This roadmap is **flexible and subject to change** based on:
- User feedback and feature requests
- App Store performance
- Development resources
- Competitive landscape
- Technical feasibility
- Islamic calendar (Ramadan timing)

**Priority changes if:**
- Critical bugs discovered → fix immediately
- User requests overwhelmingly favor one feature → reprioritize
- Competitor launches similar feature → accelerate or skip
- Technical roadblocks → defer or redesign

---

## Success Metrics Summary

| Version | Downloads Target | Rating Target | Premium Conv. | Key Metric |
|---------|-----------------|---------------|---------------|------------|
| v1.0 | 10k (Month 1) | 4.7+ | 20% | Launch success |
| v1.1 | +5k | 4.7+ | 22% | Retention |
| v1.2 | +10k | 4.8+ | 25% | Watch adoption |
| v1.3 | +15k | 4.8+ | 28% | Community |
| v1.4 | +20k | 4.9+ | 30% | Innovation |

**Long-term Goal (Year 1):** 100k downloads, 4.8+ rating, #1 Islamic app in region

---

**Document Status:** Living document, updated quarterly
**Next Review:** After v1.0 launch + 1 month (user feedback)
