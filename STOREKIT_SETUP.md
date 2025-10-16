# StoreKit Premium Purchase Setup Guide

## ✅ Step 25 Complete: StoreKit Implementation

Premium IAP is now fully implemented with StoreKit 2! Follow this guide to test and deploy.

---

## 📋 What Was Built

### Files Created:
1. **`QiblaFinder/Services/StoreManager.swift`**
   - StoreKit 2 manager using modern async/await APIs
   - Product loading, purchasing, restoration, verification
   - Automatic transaction listening
   - Error handling for all edge cases

2. **`QiblaFinder.storekit`**
   - Local StoreKit Configuration file for testing
   - Product: `com.qiblafinder.premium` - $2.99 Non-Consumable

### Files Modified:
3. **`QiblaFinder/ViewModels/SettingsViewModel.swift`**
   - Integrated StoreManager
   - Removed local isPremium management
   - Added purchasePremium() and restorePurchases() methods

4. **`QiblaFinder/Views/Settings/SettingsView.swift`**
   - Loading overlay during purchase
   - Error alerts for failed purchases
   - "Restore Purchases" button (App Store requirement)
   - Purchase button now triggers actual StoreKit flow

---

## 🧪 Local Testing (Xcode Simulator/Device)

### Step 1: Add StoreKit Configuration to Xcode

1. Open `QiblaFinder.xcodeproj` in Xcode
2. In Project Navigator, right-click on the project root
3. Select **"Add Files to QiblaFinder..."**
4. Choose `QiblaFinder.storekit`
5. Ensure "Copy items if needed" is checked
6. Click "Add"

### Step 2: Enable StoreKit Testing

1. In Xcode, go to **Product > Scheme > Edit Scheme...**
2. Select **Run** from the left sidebar
3. Go to the **Options** tab
4. Under **StoreKit Configuration**, select **QiblaFinder.storekit**
5. Click "Close"

### Step 3: Test Purchase Flow

1. **Build and Run** the app (⌘R)
2. Navigate to **Settings** tab
3. Scroll to "Upgrade to Premium" section
4. Tap **"Upgrade to Premium"** button
5. You should see:
   - Loading overlay with "Processing purchase..."
   - StoreKit sandbox purchase sheet
   - Price shows as "$2.99"
6. Tap **"Subscribe"** in the sandbox sheet
7. Premium should unlock immediately:
   - Checkmark with "Thank you" message
   - Theme picker unlocks
   - Notifications toggle unlocks
8. **Kill and restart** the app - premium should persist

### Step 4: Test Restore Purchases

1. **Reset premium status** (for testing only):
   ```swift
   // Temporarily add this to a button in SettingsView:
   UserDefaults.standard.set(false, forKey: Constants.UserDefaultsKeys.isPremium)
   ```
2. Restart the app - premium should be locked
3. Tap **"Restore Purchases"** button
4. Premium should unlock again with "Premium restored successfully"

### Step 5: Test Error Scenarios

You can enable simulated errors in the StoreKit Configuration:

1. In Xcode Project Navigator, open **QiblaFinder.storekit**
2. In the editor, go to **Editor > Enable Interrupted Purchases**
3. Run the app and test cancellation:
   - Tap purchase button
   - Tap "Cancel" in sandbox sheet
   - No error should show (expected behavior)

---

## 🚀 App Store Connect Setup (Before Submission)

### Step 1: Create IAP Product in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app **QiblaFinder**
3. Go to **Features > In-App Purchases**
4. Click **"+"** to create new IAP
5. Select **Non-Consumable**
6. Fill in product details:
   - **Product ID**: `com.qiblafinder.premium`
   - **Reference Name**: QiblaFinder Premium
   - **Price**: $2.99 (Tier 3)
7. Add localization (English):
   - **Display Name**: QiblaFinder Premium
   - **Description**: Unlock all premium features including prayer notifications, custom themes, Apple Watch app, home screen widgets, and more.
8. Upload a screenshot of the premium section (required)
9. Click **Save**

### Step 2: Add In-App Purchase Capability

1. In Xcode, select the **QiblaFinder** target
2. Go to **Signing & Capabilities** tab
3. Click **"+ Capability"**
4. Search for and add **"In-App Purchase"**

### Step 3: Test with Sandbox Account

1. Go to **App Store Connect > Users and Access > Sandbox Testers**
2. Create a new sandbox tester account
3. On your test device:
   - Go to **Settings > App Store**
   - Scroll to **Sandbox Account**
   - Sign in with sandbox tester credentials
4. Run the app from Xcode on the device
5. Test full purchase flow with sandbox account

### Step 4: App Review Information

When submitting to App Store, provide this in App Review Information:

**IAP Testing Instructions:**
```
To test premium features:
1. Navigate to Settings tab
2. Scroll to "Upgrade to Premium" section
3. Tap "Upgrade to Premium" button
4. Complete purchase
5. Premium features will unlock:
   - Custom themes (App Theme picker)
   - Prayer notifications (toggle + time selector)
6. All features work without premium purchase - this is optional upgrade only
```

---

## 🔍 Verification Checklist

Before submitting to App Store:

- [ ] Product ID matches exactly: `com.qiblafinder.premium`
- [ ] IAP product created in App Store Connect
- [ ] IAP product status is "Ready to Submit"
- [ ] Tested purchase on physical device with sandbox account
- [ ] Tested "Restore Purchases" button
- [ ] Premium features remain unlocked after app restart
- [ ] Premium features remain unlocked after app reinstall (if restored)
- [ ] Error handling works (cancel, network failure)
- [ ] Loading indicator shows during purchase
- [ ] App works perfectly without purchasing premium (free tier functional)

---

## 🐛 Troubleshooting

### "Product not found" error
- Ensure `QiblaFinder.storekit` is added to Xcode project
- Verify StoreKit Configuration is selected in scheme settings
- Clean build folder (⌘⇧K) and rebuild

### Premium doesn't persist after restart
- Check that `StoreManager.shared` is properly initialized
- Verify `isPremium` is saved to UserDefaults in `StoreManager.unlockPremium()`

### Purchase sheet doesn't appear
- Ensure you're running on iOS 15.0+ (StoreKit 2 requirement)
- Check that product loads successfully (check console for "✅ Loaded product")
- Verify network connection

### "Cannot connect to App Store" in production
- Wait 2-4 hours after creating IAP in App Store Connect
- Ensure IAP status is "Ready to Submit" not "Waiting for Upload"
- Sign out of App Store on device and sign back in

---

## 📊 Current Status

**✅ Step 25 Complete (StoreKit Implementation)**

**Progress: 20/35 steps (57.1%)**

**Next Launch-Critical Steps:**
- Step 20: App Icon & Launch Screen
- Step 26: Privacy Policy & Terms
- Final testing & App Store submission

---

## 💡 Testing Tips

1. **Always test on physical device** - Simulator StoreKit testing can be unreliable
2. **Use sandbox accounts** - Never use real Apple ID for testing
3. **Test restore flow** - App Store requires this functionality
4. **Test without purchase** - Ensure free features still work perfectly
5. **Monitor console logs** - StoreManager prints helpful debug info (✅/❌/⚠️)

---

## 📝 Notes

- **Product Type**: Non-Consumable (one-time purchase, lifetime access)
- **Price**: $2.99 USD (App Store handles currency conversion)
- **Restore**: Automatic via StoreKit 2 transaction listening
- **Receipt Validation**: Handled by StoreKit 2 `VerificationResult`
- **Family Sharing**: Currently disabled (can enable in App Store Connect)

The StoreKit implementation follows Apple's best practices and uses modern StoreKit 2 APIs with async/await for a clean, reliable purchase experience.
