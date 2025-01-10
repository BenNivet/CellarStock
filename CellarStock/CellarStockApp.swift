//
//  CellarStockApp.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import FirebaseCore
import GoogleMobileAds
import SwiftUI
import SwiftData
import TipKit

@main
struct CellarStockApp: App {
    
    @StateObject private var entitlementManager: EntitlementManager
    @StateObject private var dataManager: DataManager
    @StateObject private var subscriptionsManager: SubscriptionsManager
    @StateObject private var interstitialAdsManager = InterstitialAdsManager()
    
    init() {
        FirebaseApp.configure()
        let entitlementManager = EntitlementManager()
        entitlementManager.appLaunched += 1
        let dataManager = DataManager()
        let subscriptionsManager = SubscriptionsManager(entitlementManager: entitlementManager,
                                                        dataManager: dataManager)
        
        _entitlementManager = StateObject(wrappedValue: entitlementManager)
        _dataManager = StateObject(wrappedValue: dataManager)
        _subscriptionsManager = StateObject(wrappedValue: subscriptionsManager)
        
        try? Tips.configure([
            .displayFrequency(.daily)
        ])
        
        Task {
            if !entitlementManager.isPremium,
               entitlementManager.appLaunched > CharterConstants.minimumAppLaunch {
                await GADMobileAds.sharedInstance().start()
            }
            await subscriptionsManager.updatePurchasedProducts()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if entitlementManager.userId != nil {
                InitTabView()
                    .environmentObject(entitlementManager)
                    .environmentObject(subscriptionsManager)
                    .environmentObject(interstitialAdsManager)
                    .environmentObject(dataManager)
                    .fontDesign(.rounded)
            } else {
                InitTabView()
                    .modelContainer(for: User.self)
                    .environmentObject(entitlementManager)
                    .environmentObject(subscriptionsManager)
                    .environmentObject(interstitialAdsManager)
                    .environmentObject(dataManager)
                    .fontDesign(.rounded)
            }
        }
    }
}
