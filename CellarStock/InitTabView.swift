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
    
    @State private var users: [User] = []
    @State private var wines = 0
    @State private var quantities = 0
    
    @State private var isLoaderPresented = true
    @State private var reload = false
    @State private var initDone = false
    @State private var alreadyFetched = false
    
    private let firestoreManager = FirestoreManager.shared
    
    var body: some View {
        main
            .onChange(of: reload) { _ , newValue in
                if newValue {
                    Task {
                        isLoaderPresented = true
                        initData()
                        await fetchFromServer()
                    }
                }
            }
            .loader(isPresented: $isLoaderPresented)
    }
    
    @ViewBuilder
    private var main: some View {
        if users.isEmpty, !initDone {
            NavigationStack {
                Image("wallpaper1")
                    .resizable()
                    .ignoresSafeArea()
                    .navigationTitle(String(localized: "Vino Cave"))
            }
            .task {
                initData()
                initDone = true
            }
        } else if wines == 0 {
            ContentView(tabType: .region, reload: $reload)
                .task {
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
                if wines > 5 {
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
    
    private func initData() {
        users = (try? modelContext.fetch(FetchDescriptor<User>())) ?? []
        wines = (try? modelContext.fetchCount(FetchDescriptor<Wine>())) ?? 0
        quantities = (try? modelContext.fetchCount(FetchDescriptor<Quantity>())) ?? 0
    }
    
    private func fetchIfNeeded() async {
        if !alreadyFetched {
            await fetchFromServer()
        }
    }
    
    private func fetchFromServer() async {
        if let userId = users.first?.documentId {
            async let wines = firestoreManager.fetchWines(for: userId)
            async let quantities = firestoreManager.fetchQuantities(for: userId)
            updateModel(wines: await wines, quantities: await quantities)
        } else {
            isLoaderPresented = false
        }
    }
    
    private func updateModel(wines: [Wine], quantities: [Quantity]) {
        do {
            if self.wines != wines.count {
                try modelContext.transaction {
                    try modelContext.delete(model: Wine.self)
                    for wine in wines {
                        modelContext.insert(wine)
                    }
                    self.wines = (try? modelContext.fetchCount(FetchDescriptor<Wine>())) ?? 0
                }
            }
            
            if self.quantities != quantities.count {
                try modelContext.transaction {
                    try modelContext.delete(model: Quantity.self)
                    for quantity in quantities {
                        modelContext.insert(quantity)
                    }
                    self.quantities = (try? modelContext.fetchCount(FetchDescriptor<Quantity>())) ?? 0
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
