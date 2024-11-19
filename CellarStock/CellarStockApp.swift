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
    @StateObject private var subscriptionsManager: SubscriptionsManager
    @StateObject private var interstitialAdsManager = InterstitialAdsManager()
    @StateObject private var dataManager = DataManager()
    
    init() {
        FirebaseApp.configure()
        let entitlementManager = EntitlementManager()
        entitlementManager.appLaunched += 1
        let subscriptionsManager = SubscriptionsManager(entitlementManager: entitlementManager)
        
        _entitlementManager = StateObject(wrappedValue: entitlementManager)
        _subscriptionsManager = StateObject(wrappedValue: subscriptionsManager)
        
        try? Tips.configure([
            .displayFrequency(.daily)
        ])
        
        Task {
            if !entitlementManager.isPremium,
               entitlementManager.winesSubmitted > 5 {
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
