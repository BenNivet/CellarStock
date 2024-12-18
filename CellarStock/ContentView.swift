//
//  ContentView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import AppTrackingTransparency
import Combine
import FirebaseAnalytics
import SwiftUI
import SwiftData
import TipKit

enum TabType {
    case region
    case type
    case year
}

struct ContentView: View {
    let tabType: TabType
    @Binding var reload: Bool
    
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
    @EnvironmentObject private var interstitialAdsManager: InterstitialAdsManager
    @EnvironmentObject private var dataManager: DataManager
    
    @State private var showingSheet: (Bool, Wine, [Int: Int], [Int: Double], Bool) = (false, Wine(), [:], [:], false)
    @State private var searchText = ""
    @State private var searchIsActive = false
    @State private var showingCodeAlert = false
    @State private var codeText = ""
    @State private var showingSubscription = false
    @State private var accordionCollapsedStates: [AnyHashable: Bool] = [:]
    
    private var wines: [Wine] {
        dataManager.wines
    }
    private var filteredWines: [Wine] {
        guard !searchText.isEmpty else { return wines }
        return wines.filter { $0.isMatch(for: searchText) }
    }
    
    private var backgroundImageName: String {
        switch tabType {
        case .region:
            "wallpaper1"
        case .type:
            "wallpaper2"
        case .year:
            "wallpaper3"
        }
    }
    
    private var title = String(localized: "Vino Cave")
    private var countries: [Country] {
        Array(Set(filteredWines.compactMap { $0.country }.filter { $0 != .france }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var regions: [Region] {
        Array(Set(filteredWines.filter { $0.country == .france }.compactMap { $0.region }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var appelations: [Appelation] {
        Array(Set(filteredWines.filter { $0.country == .france && $0.region == .bordeaux }
            .compactMap { $0.appelation }))
            .sorted { $0.description < $1.description }
    }
    private var usAppelations: [USAppelation] {
        Array(Set(filteredWines.filter { $0.country == .usa }
            .compactMap { $0.usAppelation }))
            .sorted { $0.description < $1.description }
    }
    private var types: [WineType] {
        Array(Set(filteredWines.compactMap { $0.type }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var years: [Int] {
        Array(Set(dataManager.quantities.compactMap { $0.year })).sorted(by: >)
    }
    
    private var addTip = AddTip()
    
    init(tabType: TabType, reload: Binding<Bool>) {
        self.tabType = tabType
        _reload = reload
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingCodeAlert = true
                        } label: {
                            Image(systemName: "person.2.fill")
                        }
                        .foregroundStyle(.white)
                        .alert("Rejoindre une cave", isPresented: $showingCodeAlert) {
                            TextField("Code", text: $codeText)
                                .autocorrectionDisabled()
                            Button("Annuler", role: .cancel) {}
                            Button("OK") {
                                findCellar(code: codeText)
                            }
                        } message: {
                            Text("Veuillez entrer le code de la cave")
                        }
                    }
                    ToolbarItem {
                        Button {
                            entitlementManager.winesPlus += 1
                            if subscriptionsManager.needSubscription {
                                showingSubscription = true
                            } else {
                                showingSheet = (true, Wine(), [:], [:], false)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                        .foregroundStyle(.white)
                        .fullScreenCover(isPresented: $showingSheet.0) {
                            FormView(wine: $showingSheet.1,
                                     quantitiesByYear: $showingSheet.2,
                                     pricesByYear: $showingSheet.3,
                                     showQuantitiesOnly: $showingSheet.4)
                            .analyticsScreen(name: ScreenName.addWine, class: ScreenName.addWine)
                        }
                        .if(wines.isEmpty) {
                            $0.popoverTip(addTip) { _ in
                                showingSheet = (true, Wine(), [:], [:], false)
                                addTip.invalidate(reason: .actionPerformed)
                            }
                            .tipCornerRadius(CharterConstants.radius)
                        }
                    }
                }
                .fullScreenCover(isPresented: $showingSubscription) {
                    SubscriptionView()
                }
                .toolbarBackground(searchIsActive ? .visible : .automatic, for: .navigationBar)
                .background {
                    Image(backgroundImageName)
                        .resizable()
                        .ignoresSafeArea()
                }
        }
        .onOpenURL { url in
            handleURL(url: url)
        }
        .if(!dataManager.wines.isEmpty) { view in
            view.addSearchIfNeeded(for: tabType, searchText: $searchText, searchIsActive: $searchIsActive)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if filteredWines.isEmpty {
            VStack(spacing: CharterConstants.margin) {
                Spacer()
                VStack(spacing: CharterConstants.margin) {
                    if searchText.isEmpty {
                        Text("La cave est vide")
                            .font(.title)
                            .analyticsScreen(name: ScreenName.emptyWineList, class: ScreenName.emptyWineList)
                        Text("Ajouter un vin en cliquant sur le bouton \(Image(systemName: "plus"))")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Aucun résultat")
                            .font(.title)
                    }
                }
                .padding(.horizontal, CharterConstants.marginLarge)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: CharterConstants.margin) {
                    switch tabType {
                    case .region:
                        ForEach(regions) { region in
                            Accordion(title: region.description,
                                      subtitle: quantity(for: region).bottlesString,
                                      isCollapsed: isCollapsed(item: region, array: regions + countries)) {
                                regionView(region: region)
                            }
                        }
                        ForEach(countries) { country in
                            Accordion(title: country.description,
                                      subtitle: quantity(for: country).bottlesString,
                                      isCollapsed: isCollapsed(item: country, array: regions + countries)) {
                                countryView(country: country)
                            }
                        }
                    case .type:
                        ForEach(types) { type in
                            Accordion(title: type.description,
                                      subtitle: quantity(for: type).bottlesString,
                                      isCollapsed: isCollapsed(item: type, array: types)) {
                                LazyVStack(spacing: CharterConstants.marginSmall) {
                                    ForEach(filteredWines.filter { $0.type == type }) { wine in
                                        cellView(wine: wine)
                                    }
                                }
                            }
                        }
                    case .year:
                        ForEach(years, id: \.self) { year in
                            Accordion(title: year == CharterConstants.withoutYear ? String(localized: "Sans millésime") : String(year),
                                      subtitle: quantity(for: year).bottlesString,
                                      isCollapsed: isCollapsed(item: year, array: years)) {
                                yearView(year: year)
                            }
                        }
                    }
                }
                .padding(CharterConstants.margin)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                reload = true
            }
            .analyticsScreen(name: ScreenName.wineList, class: ScreenName.wineList)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in })
            }
            .onReceive(interstitialAdsManager.$interstitialAdLoaded) { isInterstitialAdLoaded in
                if !entitlementManager.isPremium,
                   isInterstitialAdLoaded {
                    interstitialAdsManager.displayInterstitialAd()
                }
            }
            .onChange(of: searchText) {
                accordionCollapsedStates.removeAll()
            }
        }
    }
    
    @ViewBuilder
    private func regionView(region: Region) -> some View {
        if region == .bordeaux {
            LazyVStack(spacing: CharterConstants.margin) {
                ForEach(appelations) { appelation in
                    Accordion(title: appelation.description,
                              subtitle: quantity(for: appelation).bottlesString,
                              isCollapsed: isCollapsed(item: appelation, array: appelations)) {
                        LazyVStack(spacing: CharterConstants.marginSmall) {
                            ForEach(filteredWines.filter { $0.country == .france && $0.region == region && $0.appelation == appelation }) { wine in
                                cellView(wine: wine)
                            }
                        }
                    }
                }
            }
        } else {
            LazyVStack(spacing: CharterConstants.marginSmall) {
                ForEach(filteredWines.filter { $0.country == .france && $0.region == region }) { wine in
                    cellView(wine: wine)
                }
            }
        }
    }
    
    @ViewBuilder
    private func countryView(country: Country) -> some View {
        if country == .usa {
            usAppelationView
        } else {
            LazyVStack(spacing: CharterConstants.marginSmall) {
                ForEach(filteredWines.filter { $0.country == country }) { wine in
                    cellView(wine: wine)
                }
            }
        }
    }
    
    @ViewBuilder
    private var usAppelationView: some View {
        LazyVStack(spacing: CharterConstants.margin) {
            ForEach(usAppelations) { usAppelation in
                Accordion(title: usAppelation.description,
                          subtitle: quantity(for: usAppelation).bottlesString,
                          isCollapsed: isCollapsed(item: usAppelation, array: usAppelations)) {
                    LazyVStack(spacing: CharterConstants.marginSmall) {
                        ForEach(filteredWines.filter { $0.country == .usa && $0.usAppelation == usAppelation }) { wine in
                            cellView(wine: wine)
                        }
                    }
                }
            }
        }
    }
    
    private func yearView(year: Int) -> some View {
        LazyVStack(spacing: CharterConstants.marginSmall) {
            ForEach(wines(for: year), id: \.0.id) { wine, quantity in
                cellView(wine: wine, yearQuantity: quantity)
            }
        }
    }
    
    private func cellView(wine: Wine, yearQuantity: Int? = nil) -> some View {
        ZStack(alignment: .topTrailing) {
            TileView {
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text(wine.name)
                            .font(.body)
                        if wine.country == .france {
                            Text(wine.region.description)
                                .font(.caption)
                            if tabType != .region, wine.region == .bordeaux, wine.appelation != .other {
                                Text(wine.appelation.description)
                                    .font(.caption)
                            }
                        } else {
                            Text(wine.country.description)
                                .font(.caption)
                            if tabType != .region, wine.country == .usa, wine.usAppelation != .other {
                                Text(wine.usAppelation.description)
                                    .font(.caption)
                            }
                        }
                        Text(wine.type.description)
                            .font(.caption)
                        if wine.size != .bouteille {
                            Text(wine.size.description.components(separatedBy: " ").first ?? "")
                                .font(.caption)
                        }
                        if !wine.owner.isEmpty {
                            Text(wine.owner)
                                .font(.caption)
                        }
                    }
                    Stepper { } onIncrement: { } onDecrement: { }
                        .opacity(0)
                }
            } action: {
                showingSheet = (true, wine, quantitiesDict(for: wine).0, quantitiesDict(for: wine).1, false)
            }
            HStack(alignment: .top) {
                Spacer()
                VStack(alignment: .trailing) {
                    Stepper {
                        
                    } onIncrement: {
                        showingSheet = (true, wine, quantitiesDict(for: wine).0, quantitiesDict(for: wine).1, true)
                    } onDecrement: {
                        showingSheet = (true, wine, quantitiesDict(for: wine).0, quantitiesDict(for: wine).1, true)
                    }
                    Text((yearQuantity ?? quantity(for: wine)).bottlesString)
                        .font(.caption)
                }
                .padding(.trailing, CharterConstants.margin)
            }
            .padding(.top, CharterConstants.margin)
        }
    }
}

// MARK: - Helper
private extension ContentView {
    
    func quantitiesDict(for wine: Wine) -> ([Int: Int], [Int: Double]) {
        var quantitiesResult: [Int: Int] = [:]
        var pricesResult: [Int: Double] = [:]
        let array = dataManager.quantities.filter { $0.wineId == wine.wineId }
        for quantity in array {
            quantitiesResult[quantity.year] = quantity.quantity
            pricesResult[quantity.year] = quantity.price
        }
        return (quantitiesResult, pricesResult)
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
        for wine in filteredWines where wine.country == country {
            result += quantity(for: wine)
        }
        return result
    }
    
    func quantity(for region: Region) -> Int {
        var result = 0
        for wine in filteredWines where wine.country == .france && wine.region == region {
            result += quantity(for: wine)
        }
        return result
    }
    
    func quantity(for appelation: Appelation) -> Int {
        var result = 0
        for wine in filteredWines where wine.country == .france && wine.region == .bordeaux && wine.appelation == appelation {
            result += quantity(for: wine)
        }
        return result
    }
    
    func quantity(for usAppelation: USAppelation) -> Int {
        var result = 0
        for wine in filteredWines where wine.country == .usa && wine.usAppelation == usAppelation {
            result += quantity(for: wine)
        }
        return result
    }
    
    func quantity(for type: WineType) -> Int {
        var result = 0
        for wine in filteredWines where wine.type == type {
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
    
    func wines(for year: Int) -> [(Wine, Int)] {
        var result: [(Wine, Int)] = []
        for quantity in dataManager.quantities where quantity.year == year {
            guard let wine = filteredWines.first(where: { $0.wineId == quantity.wineId }) else { break }
            result.append((wine, quantity.quantity))
        }
        return result
    }
    
    func findCellar(code: String) {
        Task {
            let userId = await FirestoreManager.shared.findUser(id: code)
            guard let userId else { return }
            dataManager.reset()
            entitlementManager.userId = userId
            reload = true
            Analytics.logEvent(LogEvent.joinCellar, parameters: nil)
        }
    }
    
    func handleURL(url: URL) {
        guard let codeKey = url.host(), codeKey == "code" else { return }
        findCellar(code: url.lastPathComponent)
    }
    
    func isCollapsed(item: AnyHashable, array: [any Hashable]) -> Binding<Bool> {
        Binding<Bool> {
            accordionCollapsedStates[item] ?? (array.count > 1 ? true : false)
        } set: { newValue in
            accordionCollapsedStates[item] = newValue
        }
    }
}

extension View {
    
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func addSearchIfNeeded(for tabType: TabType, searchText: Binding<String>, searchIsActive: Binding<Bool>) -> some View {
        switch tabType {
        case .region, .type:
            self
                .searchable(text: searchText, isPresented: searchIsActive, prompt: "Rechercher")
                .autocorrectionDisabled()
        case .year:
            self
        }
    }
}
