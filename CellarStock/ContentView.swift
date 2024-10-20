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
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var interstitialAdsManager: InterstitialAdsManager
    
    @Query private var users: [User]
    @Query private var wines: [Wine]
    @Query private var quantities: [Quantity]
    @State private var showingSheet: (Bool, Wine, [Int: Int], [Int: Double], Bool) = (false, Wine(), [:], [:], false)
    @State private var searchText = ""
    @State private var searchIsActive = false
    @State private var showingCodeAlert = false
    @State private var codeText = ""
    @State private var showingSubscription = false
    
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
    
    private var title = "Vino Cave"
    private var regions: [Region] {
        Array(Set(filteredWines.compactMap { $0.region }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var appelations: [Appelation] {
        Array(Set(filteredWines.filter { $0.region == .bordeaux }
            .compactMap { $0.appelation }))
            .sorted { $0.description < $1.description }
    }
    private var types: [WineType] {
        Array(Set(filteredWines.compactMap { $0.type }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var years: [Int] {
        Array(Set(quantities.compactMap { $0.year })).sorted(by: >)
    }
    
    private var addTip = AddTip()
    
    init(tabType: TabType) {
        self.tabType = tabType
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Button {
//                            importWines()
//                        } label: {
//                            Image(systemName: "square.and.arrow.down")
//                                .font(.title2)
//                        }
//                        .foregroundStyle(.white)
//                    }
//                    ToolbarItem(placement: .topBarLeading) {
//                        Button {
//                            clean()
//                        } label: {
//                            Image(systemName: "trash")
//                                .font(.title2)
//                        }
//                        .foregroundStyle(.white)
//                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingCodeAlert = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
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
                            if wines.count >= 5,
                               !entitlementManager.isPremium {
//                                showingSubscription = true
                                showingSheet = (true, Wine(), [:], [:], false)
                                Analytics.logEvent(LogEvent.needSubscription, parameters: ["wines": wines.count])
                            } else {
                                showingSheet = (true, Wine(), [:], [:], false)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                        .foregroundStyle(.white)
                        .sheet(isPresented: $showingSheet.0) {
                            FormView(wine: $showingSheet.1,
                                     quantitiesByYear: $showingSheet.2,
                                     pricesByYear: $showingSheet.3,
                                     showQuantitiesOnly: $showingSheet.4)
                            .analyticsScreen(name: ScreenName.addWine, class: ScreenName.addWine)
                        }
                        .if(wines.count == 0) {
                            $0.popoverTip(addTip) { _ in
                                showingSheet = (true, Wine(), [:], [:], false)
                                addTip.invalidate(reason: .actionPerformed)
                            }
                            .tipCornerRadius(CharterConstants.radiusSmall)
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
        .if(!wines.isEmpty) { view in
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
                VStack(spacing: CharterConstants.margin) {
                    switch tabType {
                    case .region:
                        ForEach(regions) { region in
                            Accordion(title: region.description,
                                      subtitle: quantity(for: region).bottlesString) {
                                regionView(region: region)
                            }
                        }
                    case .type:
                        ForEach(types) { type in
                            Accordion(title: type.description,
                                      subtitle: quantity(for: type).bottlesString) {
                                VStack(spacing: CharterConstants.marginSmall) {
                                    ForEach(filteredWines.filter { $0.type == type }) { wine in
                                        cellView(wine: wine)
                                    }
                                }
                            }
                        }
                    case .year:
                        ForEach(years, id: \.self) { year in
                            Accordion(title: String(year),
                                      subtitle: quantity(for: year).bottlesString) {
                                yearView(year: year)
                            }
                        }
                    }
                    
                }
                .padding(CharterConstants.margin)
            }
            .analyticsScreen(name: ScreenName.wineList, class: ScreenName.wineList)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in })
            }
            .onReceive(interstitialAdsManager.$interstitialAdLoaded) { isInterstitialAdLoaded in
                if !entitlementManager.isPremium ,
                   isInterstitialAdLoaded {
                    interstitialAdsManager.displayInterstitialAd()
                }
            }
        }
    }
    
    @ViewBuilder
    private func regionView(region: Region) -> some View {
        if region == .bordeaux {
            VStack(spacing: CharterConstants.margin) {
                ForEach(appelations) { appelation in
                    Accordion(title: appelation.description,
                              subtitle: quantity(for: appelation).bottlesString) {
                        VStack(spacing: CharterConstants.marginSmall) {
                            ForEach(filteredWines.filter { $0.region == region && $0.appelation == appelation }) { wine in
                                cellView(wine: wine)
                            }
                        }
                    }
                }
            }
        } else {
            VStack(spacing: CharterConstants.marginSmall) {
                ForEach(filteredWines.filter { $0.region == region }) { wine in
                    cellView(wine: wine)
                }
            }
        }
    }
    
    @ViewBuilder
    private func yearView(year: Int) -> some View {
        VStack(spacing: CharterConstants.marginSmall) {
            ForEach(wines(for: year), id: \.0) { wine, quantity in
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
                        Text(wine.region.description)
                            .font(.caption)
                        if tabType != .region, wine.region == .bordeaux {
                            Text(wine.appelation.description)
                                .font(.caption)
                        }
                        Text(wine.type.description)
                            .font(.caption)
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
        let array = quantities.filter { $0.wineId == wine.wineId }
        for quantity in array {
            quantitiesResult[quantity.year] = quantity.quantity
            pricesResult[quantity.year] = quantity.price
        }
        return (quantitiesResult, pricesResult)
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
        for wine in filteredWines where wine.region == region {
            result += quantity(for: wine)
        }
        return result
    }
    
    func quantity(for appelation: Appelation) -> Int {
        var result = 0
        for wine in filteredWines where wine.region == .bordeaux && wine.appelation == appelation {
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
        for quantity in quantities where quantity.year == year {
            result += quantity.quantity
        }
        return result
    }
    
    func wines(for year: Int) -> [(Wine, Int)] {
        var result: [(Wine, Int)] = []
        for quantity in quantities where quantity.year == year {
            guard let wine = filteredWines.first(where: { $0.wineId == quantity.wineId }) else { break }
            result.append((wine, quantity.quantity))
        }
        return result
    }
    
    func flush() {
        try? modelContext.delete(model: User.self)
        try? modelContext.delete(model: Quantity.self)
        try? modelContext.delete(model: Wine.self)
        try? modelContext.save()
    }
    
    func findCellar(code: String) {
        Task {
            let userId = await FirestoreManager.shared.findUser(id: code)
            guard let userId else { return }
            flush()
            modelContext.insert(User(documentId: userId))
            try? modelContext.save()
            Analytics.logEvent(LogEvent.joinCellar, parameters: nil)
        }
    }
    
    func handleURL(url: URL) {
        guard let codeKey = url.host(), codeKey == "code" else { return }
        findCellar(code: url.lastPathComponent)
    }
    
//    func importWines() {
//        let firestoreManager = FirestoreManager.shared
//        do {
//            guard let userId = users.first?.documentId,
//                  let bundlePath = Bundle.main.path(forResource: "wines", ofType: "json"),
//                  let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
//            else { return }
//            let winesImport = try JSONDecoder().decode(Import.self, from: jsonData)
//            let winesDataFlat = winesImport.data.compactMap { $0.data(for: userId) }
//            let winesData = Helper.shared.groupImport(data: winesDataFlat)
//            
//            let dispatch = DispatchGroup()
//            winesData.forEach { wine, quantities in
//                dispatch.enter()
//                firestoreManager.insertOrUpdateWine(wine) { wineId in
//                    guard let wineId else { return }
//                    wine.wineId = wineId
//                    modelContext.insert(wine)
//                    let dispatchGroup = DispatchGroup()
//                    for quantity in quantities {
//                        quantity.wineId = wineId
//                        dispatchGroup.enter()
//                        firestoreManager.insertQuantity(quantity) { documentId in
//                            guard let documentId else { return }
//                            quantity.documentId = documentId
//                            modelContext.insert(quantity)
//                            dispatchGroup.leave()
//                        }
//                    }
//                    dispatchGroup.notify(queue: .main) {
//                        try? modelContext.save()
//                        dispatch.leave()
//                    }
//                }
//            }
//            dispatch.notify(queue: .main) {
//                try? modelContext.save()
//            }
//        } catch {
//            print(error)
//        }
//    }
//    
//    func clean() {
//        FirestoreManager.shared.clean()
//    }
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
                .searchable(text: searchText, isPresented: searchIsActive, prompt: "Recherche")
                .autocorrectionDisabled()
        case .year:
            self
        }
    }
}
