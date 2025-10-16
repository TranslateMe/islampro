import SwiftUI

/// Settings screen for prayer calculation preferences and premium features
/// Organized sections with clear visual hierarchy
///
/// Design Philosophy:
/// - Black background (app consistency)
/// - BLACK navigation bar with WHITE text (no color changes on scroll)
/// - Gold section headers (visual interest)
/// - Clear sections (Prayer Settings, Premium Features, About)
/// - Premium gating (lock icon for unavailable features)
/// - Clean, professional Settings app style
struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    @Environment(\.themeBackground) private var themeBackground
    @Environment(\.themeSecondaryBackground) private var themeSecondaryBackground
    @Environment(\.themeTextPrimary) private var themeTextPrimary
    @Environment(\.themeTextSecondary) private var themeTextSecondary
    @Environment(\.themeColor) private var themeColor
    @StateObject private var storeManager = StoreManager.shared
    @State private var showErrorAlert = false
    @State private var isVisible = false

    init() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()

        // Solid black background (not transparent)
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black

        // White text for title
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        // Apply to all navigation bar states (no color changes on scroll)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                themeBackground.ignoresSafeArea()

                // Content with staggered entrance animations
                ScrollView {
                    VStack(spacing: 32) {
                        // Prayer Settings Section
                        prayerSettingsSection
                            .staggeredEntrance(index: 0)

                        // Premium Features Section
                        premiumFeaturesSection
                            .staggeredEntrance(index: 1)

                        // Premium Status / Upgrade Section
                        // HIDDEN - All features unlocked for free
                        // premiumSection

                        // About Section
                        aboutSection
                            .staggeredEntrance(index: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
                .disabled(viewModel.isPurchasing)
                .opacity(isVisible ? 1.0 : 0.0)

                // Loading overlay during purchase with animation
                if viewModel.isPurchasing {
                    ZStack {
                        themeBackground.opacity(0.7)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: Constants.GOLD_COLOR)))
                                .scaleEffect(1.5)

                            Text(NSLocalizedString("processing_purchase", comment: "Processing purchase"))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeTextPrimary)
                        }
                    }
                    .transition(AnimationUtilities.scaleFadeTransition)
                }
            }
            .navigationTitle(NSLocalizedString("settings", comment: "Settings title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                withAnimation(AnimationUtilities.Spring.gentle) {
                    isVisible = true
                }
            }
            .alert(NSLocalizedString("purchase_error", comment: "Purchase error"), isPresented: $showErrorAlert) {
                Button(NSLocalizedString("ok", comment: "OK button"), role: .cancel) {
                    HapticFeedback.light()
                }
            } message: {
                Text(viewModel.purchaseError ?? NSLocalizedString("unknown_error", comment: "Unknown error"))
            }
            .onChange(of: viewModel.purchaseError) { _, newError in
                if newError != nil {
                    HapticFeedback.error()
                    showErrorAlert = true
                }
            }
        }
    }

    // MARK: - Prayer Settings Section

    @ViewBuilder
    private var prayerSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text(NSLocalizedString("prayer_settings", comment: "Prayer settings section"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(themeColor)

            // Calculation Method
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("calculation_method", comment: "Calculation method label"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeTextPrimary.opacity(0.8))

                Picker(NSLocalizedString("calculation_method", comment: "Calculation method"), selection: $viewModel.calculationMethod) {
                    ForEach(PrayerCalculationMethod.allCases) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color(hex: Constants.PRIMARY_GREEN))
                .onChange(of: viewModel.calculationMethod) { _, _ in
                    HapticFeedback.selection()
                }

                Text(viewModel.calculationMethod.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(themeTextSecondary)
            }
            .padding(16)
            .background(themeSecondaryBackground.opacity(0.3))
            .cornerRadius(12)

            // Madhab
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("madhab_asr", comment: "Madhab Asr calculation"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeTextPrimary.opacity(0.8))

                Picker(NSLocalizedString("madhab", comment: "Madhab"), selection: $viewModel.madhab) {
                    ForEach(PrayerMadhab.allCases) { madhab in
                        Text(madhab.rawValue).tag(madhab)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color(hex: Constants.PRIMARY_GREEN))
                .onChange(of: viewModel.madhab) { _, _ in
                    HapticFeedback.selection()
                }

                Text(viewModel.madhab.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(themeTextSecondary)
            }
            .padding(16)
            .background(themeSecondaryBackground.opacity(0.3))
            .cornerRadius(12)
        }
    }

    // MARK: - Premium Features Section

    @ViewBuilder
    private var premiumFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text(NSLocalizedString("premium_features", comment: "Premium features section"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(themeColor)

            // Theme Selector
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("app_theme", comment: "App theme label"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeTextPrimary.opacity(0.8))

                Picker(NSLocalizedString("theme", comment: "Theme"), selection: $viewModel.selectedTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color(hex: Constants.PRIMARY_GREEN))
            }
            .padding(16)
            .background(themeSecondaryBackground.opacity(0.3))
            .cornerRadius(12)

            // Notifications Toggle
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("prayer_notifications", comment: "Prayer notifications label"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeTextPrimary.opacity(0.8))

                Toggle(NSLocalizedString("enable_notifications", comment: "Enable notifications"), isOn: $viewModel.notificationsEnabled)
                    .tint(Color(hex: Constants.PRIMARY_GREEN))
                    .onChange(of: viewModel.notificationsEnabled) { oldValue, isEnabled in
                        HapticFeedback.light()
                        if isEnabled {
                            // Request notification permission when enabled
                            NotificationManager.shared.requestAuthorization()
                            // Note: NotificationCenter post happens in SettingsViewModel didSet
                            // PrayerTimesViewModel will receive it and schedule notifications
                        } else {
                            // Cancel all notifications when disabled
                            NotificationManager.shared.cancelAllNotifications()
                        }
                    }

                if viewModel.notificationsEnabled {
                    Stepper(String(format: NSLocalizedString("notify_minutes_before", comment: "Notify minutes before"), viewModel.notificationMinutesBefore),
                            value: $viewModel.notificationMinutesBefore,
                            in: 5...60,
                            step: 5)
                    .font(.system(size: 12))
                    .foregroundColor(themeTextPrimary.opacity(0.7))
                }
            }
            .padding(16)
            .background(themeSecondaryBackground.opacity(0.3))
            .cornerRadius(12)

            // Arabic Language Instructions
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "globe")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: Constants.PRIMARY_GREEN))

                    Text(NSLocalizedString("language", comment: "Language label"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeTextPrimary.opacity(0.8))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("arabic_instructions_title", comment: "How to switch to Arabic"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeTextPrimary)

                    Text(NSLocalizedString("arabic_instructions", comment: "Arabic language instructions"))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        HapticFeedback.light()
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(NSLocalizedString("open_settings", comment: "Open Settings"))
                                .font(.system(size: 12, weight: .medium))
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(Color(hex: Constants.PRIMARY_GREEN))
                    }
                }
            }
            .padding(16)
            .background(themeSecondaryBackground.opacity(0.3))
            .cornerRadius(12)
        }
    }

    // MARK: - Premium Section

    @ViewBuilder
    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text(viewModel.isPremium ? NSLocalizedString("premium_active", comment: "Premium active") : NSLocalizedString("upgrade_to_premium", comment: "Upgrade to premium"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(themeColor)

            if viewModel.isPremium {
                // Premium active
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: Constants.GOLD_COLOR))

                    Text(NSLocalizedString("thank_you_premium", comment: "Thank you for premium"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(NSLocalizedString("all_features_unlocked", comment: "All features unlocked"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(themeTextPrimary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(themeSecondaryBackground.opacity(0.3))
                .cornerRadius(16)
            } else {
                // Upgrade prompt
                VStack(alignment: .leading, spacing: 16) {
                    // Feature list
                    VStack(alignment: .leading, spacing: 12) {
                        featureRow(icon: "bell.fill", text: NSLocalizedString("feature_notifications", comment: "Feature notifications"))
                        featureRow(icon: "paintpalette.fill", text: NSLocalizedString("feature_themes", comment: "Feature themes"))
                        featureRow(icon: "globe", text: NSLocalizedString("feature_methods", comment: "Feature methods"))
                        featureRow(icon: "applewatch", text: NSLocalizedString("feature_watch", comment: "Feature watch"))
                        featureRow(icon: "square.grid.2x2.fill", text: NSLocalizedString("feature_widgets", comment: "Feature widgets"))
                    }

                    // Upgrade button
                    Button {
                        viewModel.purchasePremium()
                    } label: {
                        HStack {
                            Text(NSLocalizedString("upgrade_to_premium", comment: "Upgrade to premium"))
                                .font(.system(size: 16, weight: .semibold))

                            Spacer()

                            Text(viewModel.premiumPrice)
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color(hex: Constants.GOLD_COLOR))
                        .cornerRadius(12)
                    }

                    Text(NSLocalizedString("one_time_purchase", comment: "One time purchase"))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Restore purchases button
                    Button {
                        viewModel.restorePurchases()
                    } label: {
                        Text(NSLocalizedString("restore_purchases", comment: "Restore purchases"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: Constants.PRIMARY_GREEN))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(20)
                .background(themeSecondaryBackground.opacity(0.3))
                .cornerRadius(16)
            }
        }
    }

    // MARK: - About Section

    @ViewBuilder
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text(NSLocalizedString("about", comment: "About section"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(themeColor)

            // App info
            VStack(spacing: 12) {
                Text(NSLocalizedString("qiblafinder", comment: "QiblaFinder"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(themeTextPrimary)

                Text(NSLocalizedString("version", comment: "Version"))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(themeTextPrimary.opacity(0.7))

                Text(NSLocalizedString("app_description", comment: "App description"))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(themeTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(themeSecondaryBackground.opacity(0.3))
            .cornerRadius(12)
        }
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(themeColor)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(themeTextPrimary)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
