import SwiftUI

@main
struct QiblaFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.hasSeenOnboarding)
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsViewModel)
                .applyTheme(settingsViewModel.selectedTheme)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(isPresented: $showOnboarding)
                        .environmentObject(settingsViewModel)
                        .applyTheme(settingsViewModel.selectedTheme)
                }
        }
    }
}
