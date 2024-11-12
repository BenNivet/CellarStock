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

typealias Wine = SchemaV2.WineV2
typealias Quantity = SchemaV2.QuantityV2
typealias User = SchemaV2.User

@main
struct CellarStockApp: App {
    
    @StateObject private var entitlementManager: EntitlementManager
    @StateObject private var subscriptionsManager: SubscriptionsManager
    @StateObject private var interstitialAdsManager = InterstitialAdsManager()
    
    @State private var sharedModelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: SchemaV2.self)
        let modelConfiguration = ModelConfiguration(schema: schema)
        
        do {
            return try ModelContainer(for: schema,
                                      migrationPlan: MigrationPlan.self,
                                      configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    enum MigrationPlan: SchemaMigrationPlan {
        static var schemas: [any VersionedSchema.Type] {
            [SchemaV1.self,
             SchemaV2.self]
        }
        static var stages: [MigrationStage] {
            [migrateV1toV2]
        }
        
        static let migrateV1toV2 = MigrationStage.lightweight(
            fromVersion: SchemaV1.self,
            toVersion: SchemaV2.self
        )
    }
    
    init() {
        FirebaseApp.configure()
        let entitlementManager = EntitlementManager()
        let subscriptionsManager = SubscriptionsManager(entitlementManager: entitlementManager)
        
        _entitlementManager = StateObject(wrappedValue: entitlementManager)
        _subscriptionsManager = StateObject(wrappedValue: subscriptionsManager)
        
        try? Tips.configure([
            .displayFrequency(.daily)
        ])
        
        Task {
            if !entitlementManager.isPremium {
                await GADMobileAds.sharedInstance().start()
            }
            await subscriptionsManager.updatePurchasedProducts()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            InitTabView()
                .modelContainer(sharedModelContainer)
                .environmentObject(entitlementManager)
                .environmentObject(subscriptionsManager)
                .environmentObject(interstitialAdsManager)
                .fontDesign(.rounded)
        }
    }
}
