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
    private let dataManager: DataManager
    private var updates: Task<Void, Never>?

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()

    init(entitlementManager: EntitlementManager, dataManager: DataManager) {
        self.entitlementManager = entitlementManager
        self.dataManager = dataManager
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
        guard !entitlementManager.isPremium
        else { return false }

        return entitlementManager.winesSubmitted >= CharterConstants.cellarWinesLimitSubscription
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

extension SubscriptionsManager {
    var canDisplayFeaturesView: Bool {
        guard !entitlementManager.newFeatures2Validated,
              entitlementManager.newFeatures2DisplayedCount < CharterConstants.featuresViewMaxCountLimit,
              entitlementManager.appLaunched > CharterConstants.minimumAppLaunch,
              entitlementManager.winesSubmitted > 0
        else { return false }

        guard let minumumDate = formatter.date(from: entitlementManager.minumumNewFeatures2DisplayDate),
              Date() > minumumDate
        else { return false }

        var bottles = 0
        for quantity in dataManager.quantities {
            bottles += quantity.quantity
        }

        if bottles >= CharterConstants.featuresViewBottlesLimit {
            entitlementManager.newFeatures2DisplayedCount += 1
            let newDate = CharterConstants.featuresViewDaysInterval.days.fromNow
            entitlementManager.minumumNewFeatures2DisplayDate = formatter.string(from: newDate)
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
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                print("User cancelled!")
                break
            @unknown default:
                print("Failed to purchase the product!")
            }
        } catch {
            print("Failed to purchase the product!")
        }
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else {
                continue
            }
            if transaction.revocationDate == nil {
                purchasedProductIDs.insert(transaction.productID)
            } else {
                purchasedProductIDs.remove(transaction.productID)
            }
        }

        entitlementManager.isPremium = !purchasedProductIDs.isEmpty || entitlementManager.isAdmin
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            print(error)
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension SubscriptionsManager: SKPaymentTransactionObserver {
    func paymentQueue(_: SKPaymentQueue, updatedTransactions _: [SKPaymentTransaction]) {}

    func paymentQueue(_: SKPaymentQueue, shouldAddStorePayment _: SKPayment, for _: SKProduct) -> Bool { true }
}

extension Int {
    var days: DateInterval {
        DateInterval(unit: .day, value: self)
    }
}

public struct DateInterval {
    private typealias Interval = (unit: Calendar.Component, value: Int)
    private var intervals: [Interval] = []

    init() {}

    init(unit: Calendar.Component, value: Int) {
        intervals.append(Interval(unit: unit, value: value))
    }
}

extension DateInterval {
    private func intervalDate(negative: Bool, fromDate originDate: Date? = nil) -> Date {
        var date = originDate ?? Date()
        for interval in intervals {
            date = Calendar.current.date(byAdding: interval.unit,
                                         value: negative ? -interval.value : interval.value,
                                         to: date)!
        }

        return date
    }

    var ago: Date {
        intervalDate(negative: true)
    }

    var fromNow: Date {
        intervalDate(negative: false)
    }
}
