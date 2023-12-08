//
//  ContentView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import SwiftUI
import SwiftData

enum TabType {
    case region
    case type
    case year
}

struct ContentView: View {
    let tabType: TabType
    
    @Environment(\.modelContext) private var modelContext
    @Query private var wines: [Wine]
    @Query private var quantities: [Quantity]
    @State private var showingSheet: (Bool, Wine, [Int: Int], [Int: Double], Bool) = (false, Wine(), [:], [:], false)
    @State private var searchText = ""
    @State private var searchIsActive = false
    @State private var showingAlert = false
    
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
    
    private var title: String { "Vino Cave" }
    private var regions: [Region] {
        Array(Set(filteredWines.compactMap { $0.region }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var appelations: [Appelation] {
        Array(Set(filteredWines.filter { $0.region == .bordeaux }
            .compactMap { $0.appelation }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var types: [WineType] {
        Array(Set(filteredWines.compactMap { $0.type }))
            .sorted { $0.rawValue < $1.rawValue }
    }
    private var years: [Int] {
        Array(Set(quantities.compactMap { $0.year })).sorted(by: >)
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .toolbar {
                    if !wines.isEmpty {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showingAlert = true
                            } label: {
                                Image(systemName: "trash")
                            }
                            .foregroundStyle(.white)
                            .alert("Supprimer les données", isPresented: $showingAlert) {
                                Button("Non", role: .cancel) {}
                                Button("Oui", role: .destructive) {
                                    flush()
                                }
                            }
                        }
                    }
                    ToolbarItem {
                        Button {
                            showingSheet = (true, Wine(), [:], [:], false)
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
                        }
                    }
                }
                .toolbarBackground(searchIsActive ? .visible : .automatic, for: .navigationBar)
                .background {
                    Image(backgroundImageName)
                        .resizable()
                        .ignoresSafeArea()
                }
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
                if searchText.isEmpty {
                    Text("La cave est vide")
                        .font(.title)
                    Text("Ajouter un vin en cliquant sur le bouton +")
                        .font(.title3)
                } else {
                    Text("Aucun résultat")
                        .font(.title)
                }
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
        let array = quantities.filter { $0.id == wine.id }
        for quantity in array {
            quantitiesResult[quantity.year] = quantity.quantity
            pricesResult[quantity.year] = quantity.price
        }
        return (quantitiesResult, pricesResult)
    }
    
    func quantity(for wine: Wine) -> Int {
        var result = 0
        for quantity in quantities.filter({ $0.id == wine.id }) {
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
    
    func quantity(for appelation: Appelation) -> Int {
        var result = 0
        for wine in wines where wine.region == .bordeaux && wine.appelation == appelation {
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
    
    func wines(for year: Int) -> [(Wine, Int)] {
        var result: [(Wine, Int)] = []
        for quantity in quantities where quantity.year == year {
            guard let wine = filteredWines.first(where: { $0.id == quantity.id }) else { break }
            result.append((wine, quantity.quantity))
        }
        return result
    }
    
    func flush() {
        try? modelContext.delete(model: Quantity.self)
        try? modelContext.delete(model: Wine.self)
        try? modelContext.save()
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
                .searchable(text: searchText, isPresented: searchIsActive, prompt: "Recherche")
                .autocorrectionDisabled()
        case .year:
            self
        }
    }
}
