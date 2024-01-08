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
    
    var body: some View {
        if wines.isEmpty {
            if users.isEmpty {
                ContentView(tabType: .region)
            } else {
                ContentView(tabType: .region)
                    .onAppear {
                        fetchFromServer()
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
                if wines.count >= 20 {
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
                fetchFromServer()
            }
        }
    }
    
    func fetchFromServer() {
        let firestoreManager = FirestoreManager.shared
        if let userId = users.first?.documentId {
            firestoreManager.fetchWines(for: userId) { resultsWines in
                firestoreManager.fetchQuantities(for: userId) { resultsQuantities in
                    try? modelContext.delete(model: Quantity.self)
                    try? modelContext.delete(model: Wine.self)
                    try? modelContext.save()
                    for wine in resultsWines {
                        modelContext.insert(wine)
                    }
                    for quantity in resultsQuantities {
                        modelContext.insert(quantity)
                    }
                    try? modelContext.save()
                }
            }
        }
    }
}
