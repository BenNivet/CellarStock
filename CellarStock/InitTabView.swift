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
    @State private var reload = false
    @State private var alreadyFetched = false
    
    private let firestoreManager = FirestoreManager.shared
    
    var body: some View {
        if wines.isEmpty {
            ContentView(tabType: .region, reload: $reload)
                .task {
                    if !alreadyFetched {
                        await fetchFromServer()
                    }
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
                if !alreadyFetched {
                    await fetchFromServer()
                }
            }
            .onChange(of: reload) { _ , newValue in
                if newValue {
                    Task {
                        await fetchFromServer()
                    }
                }
            }
            .loader(isPresented: $isLoaderPresented)
        }
    }
    
    private func fetchFromServer() async {
        if let userId = users.first?.documentId {
            isLoaderPresented = true
//            Task.detached(priority: .background) {
                let wines = await firestoreManager.fetchWines(for: userId)
                let quantities = await firestoreManager.fetchQuantities(for: userId)
                updateModel(wines: wines, quantities: quantities)
//            }
        }
    }
    
    private func updateModel(wines: [Wine], quantities: [Quantity]) {
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
                endFetch()
            }
        } catch {
            endFetch()
        }
    }
    
    private func endFetch() {
        isLoaderPresented = false
        modelContext.autosaveEnabled = true
        if reload {
            reload = false
        }
        alreadyFetched = true
    }
}
