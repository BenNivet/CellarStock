//
//  InitTabView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 01/11/2023.
//

import SwiftUI
import SwiftData

struct InitTabView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Query private var wines: [Wine]
    
    private let firestoreManager = FirestoreManager.shared
    
    var body: some View {
        if wines.isEmpty {
            if users.isEmpty {
                ContentView(tabType: .region)
            } else {
                ContentView(tabType: .region)
                    .task {
                        await fetchFromServer()
                    }
            }
        } else {
            TabView {
                ContentView(tabType: .region)
                    .tabItem {
                        Text("Région")
                        Image("map")
                    }
                ContentView(tabType: .type)
                    .tabItem {
                        Text("Type")
                        Image("grape")
                    }
                ContentView(tabType: .year)
                    .tabItem {
                        Text("Année")
                        Image("calendar")
                    }
                if wines.count >= 8 {
                    RandomView()
                        .tabItem {
                            Text("Roulette")
                            Image("dice")
                        }
                }
                StatsView()
                    .tabItem {
                        Text("Stats")
                        Image("stats")
                    }
            }
            .accentColor(.white)
            .onAppear {
                UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
            }
            .task {
                await fetchFromServer()
            }
        }
    }
    
    func fetchFromServer() async {
        if let userId = users.first?.documentId {
            let wines = await firestoreManager.fetchWines(for: userId)
            let quantities = await firestoreManager.fetchQuantities(for: userId)
            updateModel(wines: wines, quantities: quantities)
        }
    }
    
    func updateModel(wines: [Wine], quantities: [Quantity]) {
        try? modelContext.delete(model: Quantity.self)
        try? modelContext.delete(model: Wine.self)
        try? modelContext.save()
        for wine in wines {
            modelContext.insert(wine)
        }
        for quantity in quantities {
            modelContext.insert(quantity)
        }
        try? modelContext.save()
    }
}
