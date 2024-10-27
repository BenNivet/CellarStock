//
//  StatsView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 03/12/2023.
//

import FirebaseAnalytics
import SwiftUI
import SwiftData
import TipKit

struct StatsView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var users: [User]
    @Query private var wines: [Wine]
    @Query private var quantities: [Quantity]
    
    @State private var showingSettings = false
    @State private var showingSubscription = false
    
    private var regions: [Region] {
        Array(Set(wines.compactMap { $0.region }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var types: [WineType] {
        Array(Set(wines.compactMap { $0.type }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var years: [Int] {
        Array(Set(quantities.compactMap { $0.year })).sorted(by: >)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: CharterConstants.margin) {
                VStack(spacing: CharterConstants.marginSmall) {
                    tile(left: "Total", right: generalInfos.count.bottlesString)
                    tile(left: "Montant total", right: "\(generalInfos.price.toRoundedString) €")
                }
                .padding(.horizontal, CharterConstants.margin)
                
                NeoTabsView(items: [
                    NeoTabsItemModel(title: "Régions",
                                     index: 0) {
                                         AnyView(ChartsView(data: regions.map { StepCount(name: $0.description, count: quantity(for: $0)) }))
                                     },
                    NeoTabsItemModel(title: "Types",
                                     index: 1) {
                                         AnyView(ChartsView(data: types.map { StepCount(name: $0.description, count: quantity(for: $0)) }))
                                     },
                    NeoTabsItemModel(title: "Années",
                                     index: 2) {
                                         AnyView(ChartsView(data: years.map { StepCount(name: String($0), count: quantity(for: $0)) }))
                                     }
                ])
            }
            .toolbar {
                if let userId = users.first?.documentId {
                    ToolbarItem {
                        ShareLink(item: sharedText(id: userId),
                                  preview: SharePreview("Partager ma cave"))
                    }
                }
                ToolbarItem {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .confirmationDialog("Réglages", 
                                        isPresented: $showingSettings,
                                        titleVisibility: .automatic) {
                        Button("Supprimer les données", role: .destructive) {
                            flush()
                            Analytics.logEvent(LogEvent.deleteCellar, parameters: nil)
                        }
                        //                        Button("Exporter mes données") {
                        //                            //
                        //                        }
                        Button("Annuler", role: .cancel) {}
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSubscription = true
                    } label: {
                        Image(systemName: "crown.fill")
                    }
                }
            }
            .padding(.vertical, CharterConstants.margin)
            .fullScreenCover(isPresented: $showingSubscription) {
                SubscriptionView()
            }
            .navigationTitle("Stats")
            .addLinearGradientBackground()
            .analyticsScreen(name: ScreenName.stats)
        }
    }
    
    private func tile(left: String, right: String) -> some View {
        TileView {
            HStack {
                Text(left)
                    .font(.body)
                Spacer()
                Text(right)
                    .font(.body)
            }
        }
    }
}

private extension StatsView {
    
    var generalInfos: (count: Int, price: Double) {
        var count: Int = 0
        var price: Double = 0
        for quantity in quantities {
            count += quantity.quantity
            price += quantity.price * Double(quantity.quantity)
        }
        return (count, price)
    }
    
    func quantity(for wine: Wine) -> Int {
        var result = 0
        for quantity in quantities where quantity.wineId == wine.wineId {
            result += quantity.quantity
        }
        return result
    }
    
    func quantity(for region: Region) -> Int {
        var result = 0
        for wine in wines where wine.region == region {
            result += quantity(for: wine)
        }
        return result
    }
    
    func quantity(for type: WineType) -> Int {
        var result = 0
        for wine in wines where wine.type == type {
            result += quantity(for: wine)
        }
        return result
    }
    
    func quantity(for year: Int) -> Int {
        var result = 0
        for quantity in quantities where quantity.year == year {
            result += quantity.quantity
        }
        return result
    }
    
    func sharedText(id: String) -> String {
        """
        Vino Cave
        Je souhaite partager ma cave avec toi !
        Clic sur le lien ci-dessous pour y acceder :
        vinocave://code/\(id)
        L'application Vino Cave doit déjà être installé sur le téléphone.
        """
    }
    
    func flush() {
        try? modelContext.delete(model: User.self)
        try? modelContext.delete(model: Quantity.self)
        try? modelContext.delete(model: Wine.self)
        try? modelContext.save()
    }
}

