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

typealias Wine = WineV2
typealias Quantity = QuantityV2

@main
struct CellarStockApp: App {
    
    @StateObject private var entitlementManager: EntitlementManager
    @StateObject private var subscriptionsManager: SubscriptionsManager
    @StateObject private var interstitialAdsManager = InterstitialAdsManager()
    
    @State private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Wine.self,
            Quantity.self,
            User.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        FirebaseApp.configure()
        let entitlementManager = EntitlementManager()
        let subscriptionsManager = SubscriptionsManager(entitlementManager: entitlementManager)
        
        _entitlementManager = StateObject(wrappedValue: entitlementManager)
        _subscriptionsManager = StateObject(wrappedValue: subscriptionsManager)
        
        try? Tips.configure([
            .displayFrequency(.daily)
        ])
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        Task {
            await subscriptionsManager.updatePurchasedProducts()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            InitTabView()
                .environmentObject(entitlementManager)
                .environmentObject(subscriptionsManager)
                .environmentObject(interstitialAdsManager)
                .fontDesign(.rounded)
        }
        .modelContainer(sharedModelContainer)
    }
}
