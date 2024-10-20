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
    
    @State private var isLoaderPresented = false
    
    private let firestoreManager = FirestoreManager.shared
    
    var body: some View {
        if wines.isEmpty {
            if users.isEmpty {
                ContentView(tabType: .region)
            } else {
                ContentView(tabType: .region)
                    .task {
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
                if wines.count > 5 {
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
                fetchFromServer()
            }
            .loader(isPresented: $isLoaderPresented)
        }
    }
    
    func fetchFromServer() {
        if let userId = users.first?.documentId {
            isLoaderPresented = true
            Task.detached(priority: .background) {
                let wines = await firestoreManager.fetchWines(for: userId)
                let quantities = await firestoreManager.fetchQuantities(for: userId)
                await MainActor.run {
                    updateModel(wines: wines, quantities: quantities)
                }
            }
        }
    }
    
    func updateModel(wines: [Wine], quantities: [Quantity]) {
        modelContext.autosaveEnabled = false
        do {
            try modelContext.transaction {
                try modelContext.delete(model: Quantity.self)
                try modelContext.delete(model: Wine.self)
                for wine in wines {
                    modelContext.insert(wine)
                }
                
                for quantity in quantities {
                    modelContext.insert(quantity)
                }
                if modelContext.hasChanges {
                    try modelContext.save()
                }
                isLoaderPresented = false
                modelContext.autosaveEnabled = true
            }
        } catch {
            isLoaderPresented = false
            modelContext.autosaveEnabled = true
        }
    }
}
