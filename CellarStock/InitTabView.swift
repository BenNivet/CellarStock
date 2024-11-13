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
    @EnvironmentObject private var entitlementManager: EntitlementManager
    
    @Query private var users: [User]
    @Query private var wines: [Wine]
    @Query private var quantities: [Quantity]
    
    @State private var isLoaderPresented = true
    @State private var reload = false
    @State private var alreadyFetched = false
    
    private let firestoreManager = FirestoreManager.shared
    
    var body: some View {
        Group {
            if wines.isEmpty {
                ContentView(tabType: .region, reload: $reload)
                    .task {
                        entitlementManager.clearNeeded = false
                        await fetchIfNeeded()
                    }
            } else {
                TabView {
                    ContentView(tabType: .region, reload: $reload)
                        .tabItem {
                            Text("Région")
                            Image("map")
                        }
                    ContentView(tabType: .type, reload: $reload)
                        .tabItem {
                            Text("Type")
                            Image("grape")
                        }
                    ContentView(tabType: .year, reload: $reload)
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
                    await fetchIfNeeded()
                }
            }
        }
        .onChange(of: reload) { _ , newValue in
            if newValue {
                Task {
                    isLoaderPresented = true
                    await fetchFromServer()
                }
            }
        }
        .loader(isPresented: $isLoaderPresented)
    }
    
    private func fetchIfNeeded() async {
        if !alreadyFetched {
            await fetchFromServer()
        }
    }
    
    private func fetchFromServer() async {
        if let userId = users.first?.documentId {
            if entitlementManager.clearNeeded {
                entitlementManager.clearNeeded = false
                try? modelContext.delete(model: Wine.self)
                try? modelContext.delete(model: Quantity.self)
            } else {
                async let wines = await firestoreManager.fetchWines(for: userId)
                async let quantities = await firestoreManager.fetchQuantities(for: userId)
                updateModel(wines: await wines, quantities: await quantities)
            }
        } else {
            isLoaderPresented = false
        }
    }
    
    private func updateModel(wines: [Wine], quantities: [Quantity]) {
        do {
            if self.wines.count != wines.count,
               self.wines.first(where: { wines.contains($0) }) == nil {
                try modelContext.transaction {
                    try modelContext.delete(model: Wine.self)
                    for wine in wines {
                        modelContext.insert(wine)
                    }
                }
            }
            
            if self.quantities.count != quantities.count,
               self.quantities.first(where: { quantities.contains($0) }) == nil {
                try modelContext.transaction {
                    try modelContext.delete(model: Quantity.self)
                    for quantity in quantities {
                        modelContext.insert(quantity)
                    }
                }
            }
            
            endFetch()
        } catch {
            endFetch()
        }
    }
    
    private func endFetch() {
        if reload {
            reload = false
        }
        alreadyFetched = true
        isLoaderPresented = false
    }
}
