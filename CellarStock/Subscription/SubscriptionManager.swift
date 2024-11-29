//
//  SubscriptionManager.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 06/10/2024.
//

import StoreKit

@MainActor
class SubscriptionsManager: NSObject, ObservableObject {
    let productIDs: [String] = ["Monthly", Subscription.popularId, "HalfYearly"]
    var purchasedProductIDs: Set<String> = []
    
    @Published var products: [Product] = []
    
    private let entitlementManager: EntitlementManager
    private var updates: Task<Void, Never>?
    
    init(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
        super.init()
        self.updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        updates?.cancel()
    }
    
    func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
}

// MARK: - NeedSubscription
extension SubscriptionsManager {
    var needSubscription: Bool {
        guard !entitlementManager.isPremium,
              entitlementManager.appLaunched > CharterConstants.minimumAppLaunch,
              entitlementManager.winesPlus > 0
        else { return false }
        
        if entitlementManager.winesPlus % CharterConstants.winesCountSubscription == 0 {
            entitlementManager.winesPlus += 1
            return true
        } else {
            return false
        }
    }
}

extension SubscriptionsManager {
    var needRating: Bool {
        guard entitlementManager.appLaunched > CharterConstants.minimumAppLaunch,
              entitlementManager.winesSubmitted > 0
        else { return false }
        
        if entitlementManager.winesSubmitted % CharterConstants.winesCountRatings == 0 {
            entitlementManager.winesSubmitted += 1
            return true
        } else {
            return false
        }
    }
}

// MARK: - StoreKit2 API
extension SubscriptionsManager {
    func loadProducts() async {
        do {
            let result = try await Product.products(for: productIDs)
            var tmpProduct = [Product]()
            if result.count == productIDs.count {
                for id in productIDs {
                    if let product = result.first(where: { $0.id == id }) {
                        tmpProduct.append(product)
                    }
                }
                products = tmpProduct
            } else {
                products = result
            }
        } catch {
            print("Failed to fetch products!")
        }
    }
    
    func buyProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case let .success(.verified(transaction)):
                // Successful purhcase
                await transaction.finish()
                await updatePurchasedProducts()
            case let .success(.unverified(_, error)):
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                print("Unverified purchase. Might be jailbroken. Error: \(error)")
                break
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                print("User cancelled!")
                break
            @unknown default:
                print("Failed to purchase the product!")
                break
            }
        } catch {
            print("Failed to purchase the product!")
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            if transaction.revocationDate == nil {
                purchasedProductIDs.insert(transaction.productID)
            } else {
                purchasedProductIDs.remove(transaction.productID)
            }
        }
        
        entitlementManager.isPremium = !purchasedProductIDs.isEmpty
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            print(error)
        }
    }
}

extension SubscriptionsManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {}
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool { true }
}
