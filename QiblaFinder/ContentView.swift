import SwiftUI

/// Main app structure with 4-tab navigation
/// Assembles all major features into cohesive interface
///
/// Tab Structure:
/// 1. Compass (Qibla direction) - Primary feature
/// 2. Prayer Times (5 daily prayers + sunrise) - Core feature
/// 3. Map (User → Mecca visualization) - Geographic context
/// 4. Settings (Preferences + Premium) - Configuration
///
/// Design Philosophy:
/// - Black background throughout (consistent aesthetic)
/// - Solid black tab bar with high-visibility white icons
/// - Clear SF Symbol icons (universally understood)
/// - Proper tab labels (accessibility)
/// - Four complete features (MVP approach)
struct ContentView: View {

    init() {
        // Configure tab bar appearance
        let appearance = UITabBarAppearance()

        // Solid black background (not transparent)
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black

        // Unselected tab items: Bright white for visibility
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.8)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]

        // Selected tab items: Green accent
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: Constants.PRIMARY_GREEN))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: Constants.PRIMARY_GREEN))
        ]

        // Apply to all tab bar states
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            // Tab 1: Qibla Compass
            CompassView()
                .tabItem {
                    Label("Qibla", systemImage: "location.north.circle.fill")
                }

            // Tab 2: Prayer Times
            PrayerTimesView()
                .tabItem {
                    Label("Prayer Times", systemImage: "clock.fill")
                }

            // Tab 3: Map
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            // Tab 4: Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        // Tab bar styling
        .tint(Color(hex: Constants.PRIMARY_GREEN))  // Active tab color
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
