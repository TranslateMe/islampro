import Foundation
import StoreKit
import Combine

/// StoreKit 2 manager for premium IAP purchase
/// Handles product loading, purchasing, restoration, and verification
///
/// Product ID: "com.qiblafinder.premium"
/// Price: $2.99 (one-time purchase, non-consumable)
///
/// Design Philosophy:
/// - StoreKit 2 async/await APIs (modern, clean)
/// - Automatic transaction listening (catch purchases from outside app)
/// - Receipt validation (verify legitimate purchases)
/// - Error handling (network, cancelled, invalid, etc.)
/// - Restore purchases (App Store requirement)
@MainActor
class StoreManager: ObservableObject {
    // MARK: - Published Properties

    @Published var isPremium: Bool = false
    @Published var premiumProduct: Product?
    @Published var isLoading: Bool = false
    @Published var purchaseError: String?

    // MARK: - Properties

    private let productID = "com.qiblafinder.premium"
    private var transactionListener: Task<Void, Error>?

    // MARK: - Singleton

    static let shared = StoreManager()

    // MARK: - Initialization

    private init() {
        // Start listening for transactions
        transactionListener = listenForTransactions()

        // Load premium status from cache
        isPremium = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isPremium)

        // Load products
        Task {
            await loadProducts()
            await checkPurchaseStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Product Loading

    /// Load premium product from App Store
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productID])

            if let product = products.first {
                premiumProduct = product
                print("✅ Loaded product: \(product.displayName) - \(product.displayPrice)")
            } else {
                print("⚠️ Premium product not found in App Store Connect")
            }
        } catch {
            print("❌ Failed to load products: \(error.localizedDescription)")
            purchaseError = "Failed to load premium product. Please try again later."
        }
    }

    // MARK: - Purchase

    /// Purchase premium product
    func purchasePremium() async {
        guard let product = premiumProduct else {
            purchaseError = "Premium product not available"
            return
        }

        isLoading = true
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify transaction
                let transaction = try checkVerified(verification)

                // Unlock premium
                await unlockPremium()

                // Finish transaction
                await transaction.finish()

                print("✅ Premium purchased successfully")

            case .userCancelled:
                print("ℹ️ User cancelled purchase")

            case .pending:
                print("⏳ Purchase pending approval")
                purchaseError = "Purchase pending approval. Please check back later."

            @unknown default:
                print("⚠️ Unknown purchase result")
            }
        } catch {
            print("❌ Purchase failed: \(error.localizedDescription)")
            purchaseError = "Purchase failed. Please try again."
        }

        isLoading = false
    }

    // MARK: - Restore

    /// Restore previous purchases (App Store requirement)
    func restorePurchases() async {
        isLoading = true
        purchaseError = nil

        do {
            // Sync with App Store
            try await AppStore.sync()

            // Check purchase status
            await checkPurchaseStatus()

            if isPremium {
                print("✅ Premium restored successfully")
            } else {
                print("ℹ️ No previous purchases found")
                purchaseError = "No previous purchases found"
            }
        } catch {
            print("❌ Restore failed: \(error.localizedDescription)")
            purchaseError = "Failed to restore purchases. Please try again."
        }

        isLoading = false
    }

    // MARK: - Purchase Status

    /// Check if user has purchased premium
    func checkPurchaseStatus() async {
        var hasPremium = false

        // Check all transactions for premium product
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if transaction.productID == productID {
                    hasPremium = true
                    break
                }
            } catch {
                print("⚠️ Failed to verify transaction: \(error)")
            }
        }

        // Update premium status
        if hasPremium != isPremium {
            await unlockPremium()
        }
    }

    // MARK: - Transaction Listener

    /// Listen for transactions (catches purchases made outside app)
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            guard let self = self else { return }

            // Iterate through any transactions that don't come from a direct call to purchase()
            for await result in Transaction.updates {
                do {
                    // Call checkVerified on MainActor since StoreManager is @MainActor
                    let transaction = try await MainActor.run {
                        try self.checkVerified(result)
                    }

                    // Check if it's our premium product
                    let productID = await MainActor.run { self.productID }
                    if transaction.productID == productID {
                        await self.unlockPremium()
                    }

                    // Finish transaction
                    await transaction.finish()
                } catch {
                    print("⚠️ Transaction verification failed: \(error)")
                }
            }
        }
    }

    // MARK: - Verification

    /// Verify transaction is legitimate (not jailbreak/fraud)
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            // StoreKit has parsed the JWS but failed verification
            throw StoreError.failedVerification
        case .verified(let safe):
            // Transaction is verified as legitimate
            return safe
        }
    }

    // MARK: - Premium Unlock

    /// Unlock premium features
    private func unlockPremium() async {
        isPremium = true
        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isPremium)
        print("✅ Premium unlocked")
    }

    // MARK: - Helper Properties

    /// Formatted price string for display
    var premiumPrice: String {
        premiumProduct?.displayPrice ?? "$2.99"
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
}

extension StoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        }
    }
}
