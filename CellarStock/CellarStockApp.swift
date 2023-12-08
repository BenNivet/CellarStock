//
//  CellarStockApp.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import SwiftUI
import SwiftData

@main
struct CellarStockApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Wine.self,
            Quantity.self
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
