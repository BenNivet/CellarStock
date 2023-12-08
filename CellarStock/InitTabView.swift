//
//  InitTabView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 01/11/2023.
//

import SwiftUI
import SwiftData

struct InitTabView: View {
    
    @Query private var wines: [Wine]
    
    var body: some View {
        if wines.isEmpty {
            ContentView(tabType: .region)
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
                if wines.count > 1 {
                    RandomView()
                        .tabItem {
                            Text("Roulette")
                            Image("dice")
                        }
                    StatsView()
                        .tabItem {
                            Text("Stats")
                            Image("stats")
                        }
                }
            }
            .accentColor(.white)
            .onAppear {
                UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
            }
        }
    }
}
