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
    
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var dataManager: DataManager
    
    @State private var showingSettings = false
    @State private var showingSubscription = false
    
    private var countries: [Country] {
        Array(Set(dataManager.wines.compactMap { $0.country }.filter { $0 != .france }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var regions: [Region] {
        Array(Set(dataManager.wines.filter { $0.country == .france }.compactMap { $0.region }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var types: [WineType] {
        Array(Set(dataManager.wines.compactMap { $0.type }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var years: [Int] {
        Array(Set(dataManager.quantities.compactMap { $0.year })).sorted(by: >)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: CharterConstants.margin) {
                VStack(spacing: CharterConstants.marginSmall) {
                    tile(left: String(localized: "Total"), right: generalInfos.count.bottlesString)
                    tile(left: String(localized: "Montant total"), right: "\(generalInfos.price.toRoundedString) \(String(describing: Locale.current.currencySymbol ?? "€"))")
                }
                .padding(.horizontal, CharterConstants.margin)
                
                NeoTabsView(items: [
                    NeoTabsItemModel(title: String(localized: "Régions"),
                                     index: 0) {
                                         AnyView(ChartsView(data: regions.map { StepCount(name: $0.description, count: quantity(for: $0)) } + countries.map { StepCount(name: $0.description, count: quantity(for: $0)) }))
                                     },
                    NeoTabsItemModel(title: String(localized: "Types"),
                                     index: 1) {
                                         AnyView(ChartsView(data: types.map { StepCount(name: $0.description, count: quantity(for: $0)) }))
                                     },
                    NeoTabsItemModel(title: String(localized: "Millésime"),
                                     index: 2) {
                                         AnyView(ChartsView(data: years.map {
                                             StepCount(name: $0 == CharterConstants.withoutYear ? String(localized: "Sans millésime"): String($0),
                                                       count: quantity(for: $0)) }))
                                     }
                ])
            }
            .toolbar {
                if let userId = entitlementManager.userId {
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
            .analyticsScreen(name: ScreenName.stats, class: ScreenName.stats)
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
        for quantity in dataManager.quantities {
            count += quantity.quantity
            price += quantity.price * Double(quantity.quantity)
        }
        return (count, price)
    }
    
    func quantity(for wine: Wine) -> Int {
        var result = 0
        for quantity in dataManager.quantities where quantity.wineId == wine.wineId {
            result += quantity.quantity
        }
        return result
    }
    
    func quantity(for country: Country) -> Int {
        var result = 0
        for wine in dataManager.wines where wine.country == country {
            result += quantity(for: wine)
        }
        return result
    }
    
    func quantity(for region: Region) -> Int {
        var result = 0
        for wine in dataManager.wines where wine.country == .france && wine.region == region {
            result += quantity(for: wine)
        }
        return result
    }
    
    func quantity(for type: WineType) -> Int {
        var result = 0
        for wine in dataManager.wines where wine.type == type {
            result += quantity(for: wine)
        }
        return result
    }
    
    func quantity(for year: Int) -> Int {
        var result = 0
        for quantity in dataManager.quantities where quantity.year == year {
            result += quantity.quantity
        }
        return result
    }
    
    func sharedText(id: String) -> String {
        String(localized:
        """
        Vino Cave
        Je souhaite partager ma cave avec toi !
        Clic sur le lien ci-dessous pour y acceder :
        vinocave://code/\(id)
        L'application Vino Cave doit déjà être installé sur le téléphone.
        """
        )
    }
    
    func flush() {
        entitlementManager.userId = nil
        dataManager.reset()
    }
}

