//
//  CellarStockApp.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        FirestoreManager.shared.initDb()
        return true
    }
}

@main
struct CellarStockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var sharedModelContainer: ModelContainer = {
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
    
    var body: some Scene {
        WindowGroup {
            InitTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
