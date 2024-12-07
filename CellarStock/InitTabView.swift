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
    @EnvironmentObject private var dataManager: DataManager
    
    @State private var isLoaderPresented = true
    @State private var reload = false
    @State private var dataFetched = false
    
    private let firestoreManager = FirestoreManager.shared
    
    var body: some View {
        main
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
    
    @ViewBuilder
    private var main: some View {
        if !dataFetched {
            NavigationStack {
                Image("wallpaper1")
                    .resizable()
                    .ignoresSafeArea()
                    .navigationTitle(String(localized: "Vino Cave"))
            }
            .task {
                await fetchFromServer()
            }
        } else if dataManager.wines.isEmpty {
            ContentView(tabType: .region, reload: $reload)
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
                        Text("Millésime")
                        Image("calendar")
                    }
                if dataManager.wines.count > 5 {
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
        }
    }
    
    private func fetchFromServer() async {
        if let userId = entitlementManager.userId {
            await fetch(userId: userId)
        } else if let userId = try? modelContext.fetch(FetchDescriptor<User>()).first?.documentId {
            entitlementManager.userId = userId
            await fetch(userId: userId)
        } else {
            dataFetched = true
            isLoaderPresented = false
        }
    }
    
    private func fetch(userId: String) async {
        async let wines = firestoreManager.fetchWines(for: userId)
        async let quantities = firestoreManager.fetchQuantities(for: userId)
        updateModel(wines: await wines, quantities: await quantities)
    }
    
    private func updateModel(wines: [Wine], quantities: [Quantity]) {
        dataManager.wines = wines
        dataManager.quantities = quantities
        endFetch()
    }
    
    private func endFetch() {
        if reload {
            reload = false
        }
        dataFetched = true
        isLoaderPresented = false
    }
}
