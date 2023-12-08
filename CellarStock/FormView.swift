//
//  FormView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import Foundation
import SwiftUI
import SwiftData
import VisionKit

@MainActor
struct FormView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query private var wines: [Wine]
    @Query private var quantities: [Quantity]
    @Binding var wine: Wine
    @Binding var quantitiesByYear: [Int: Int]
    @Binding var pricesByYear: [Int: Double]
    @Binding var showQuantitiesOnly: Bool
    @State private var showingSheet = false
    @State private var showingCameraSheet = false
    @State private var scannedText = ""
    @State private var showingAmountSheet = false
    @State private var selectedYearAmount: Int = 0
    @FocusState private var isTextFieldFocus: Bool
    
    var body: some View {
        if !scannedText.isEmpty {
            let linesText = scannedText.components(separatedBy: "\n")
            VStack(spacing: CharterConstants.margin) {
                HStack(spacing: CharterConstants.marginSmall) {
                    Text("Choisissez le nom du vin")
                        .font(.title2.bold())
                    Spacer()
                }
                ScrollView {
                    VStack(spacing: CharterConstants.marginSmall) {
                        ForEach(linesText, id: \.self) { lineText in
                            TileView {
                                Text(lineText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } action: {
                                wine.name = lineText
                                scannedText = ""
                            }
                        }
                    }
                    .padding(.bottom, CharterConstants.marginSmall)
                }
            }
            .padding(CharterConstants.margin)
        } else {
            formView
        }
    }
    
    private var formView: some View {
        Form {
            if !showQuantitiesOnly {
                Section("Vin") {
                    Picker("Region", selection: $wine.region) {
                        ForEach(Region.allCases) { region in
                            Text(String(describing: region))
                        }
                    }
                    if wine.region == .bordeaux {
                        Picker("Appelation", selection: $wine.appelation) {
                            ForEach(Appelation.allCases) { appelation in
                                Text(String(describing: appelation))
                            }
                        }
                    }
                    Picker("Type", selection: $wine.type) {
                        ForEach(WineType.allCases) { type in
                            Text(String(describing: type))
                        }
                    }
                    HStack {
                        TextField("Nom", text: $wine.name)
                            .focused($isTextFieldFocus)
                        if scannerAvailable {
                            Button {
                                isTextFieldFocus = false
                                showingCameraSheet = true
                            } label: {
                                Image(systemName: "camera")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .foregroundStyle(.white)
                        }
                    }
                }
            }
            
            Section("Quantité") {
                ForEach(quantitiesByYear.keys.sorted(by: >), id: \.self) { year in
                    VStack(alignment: .leading, spacing: CharterConstants.marginSmall) {
                        HStack {
                            Text(String(year))
                            Spacer()
                            VStack(alignment: .trailing) {
                                Stepper {
                                    
                                } onIncrement: {
                                    quantitiesByYear[year] = (quantitiesByYear[year] ?? 0) + 1
                                } onDecrement: {
                                    guard let quantity = quantitiesByYear[year] else { return }
                                    if quantity > 1 {
                                        quantitiesByYear[year] = (quantity - 1)
                                    } else {
                                        quantitiesByYear[year] = nil
                                    }
                                }
                                Text((quantitiesByYear[year] ?? 0).bottlesString)
                                    .font(.caption)
                            }
                        }
                        HStack {
                            Spacer()
                            Text("\(String(Int(pricesByYear[year] ?? 0))) €")
                        }
                        .onTapGesture {
                            isTextFieldFocus = false
                            selectedYearAmount = year
                        }
                    }
                }
                Button("Ajouter une année") {
                    isTextFieldFocus = false
                    showingSheet = true
                }
            }
            
            if !showQuantitiesOnly {
                Section("Infos") {
                    TextField("Vigneron / Domaine", text: $wine.owner)
                        .focused($isTextFieldFocus)
                    TextField("Infos", text: $wine.info)
                        .focused($isTextFieldFocus)
                }
            }
            
            Section("") {
                Button("Sauvegarder") {
                    save()
                    dismiss()
                }
                .disabled(wine.name.isEmpty)
            }
        }
        .sheet(isPresented: $showingSheet) {
            YearSelectionListView(availableYears: Helper.shared.availableYears(for: wine,
                                                                               selectedYears: Array(quantitiesByYear.keys)),
                                  quantities: $quantitiesByYear,
                                  prices: $pricesByYear)
        }
        .sheet(isPresented: $showingCameraSheet) {
            DocumentScannerView(selectedText: $scannedText)
        }
        .sheet(isPresented: bindingAmount) {
            AmountView(year: $selectedYearAmount, pricesByYear: $pricesByYear)
        }
        .autocorrectionDisabled()
    }
}

private extension FormView {
    
    var scannerAvailable: Bool {
        DataScannerViewController.isSupported &&
        DataScannerViewController.isAvailable
    }
    
    var bindingAmount: Binding<Bool> {
        Binding {
            selectedYearAmount != 0
        } set: { _ in }
    }
    
    func save() {
        guard !quantitiesByYear.isEmpty else {
            for quantity in quantities.filter({ $0.id == wine.id }) {
                modelContext.delete(quantity)
            }
            try? modelContext.save()
            if wines.contains(wine) {
                modelContext.delete(wine)
            }
            try? modelContext.save()
            return
        }
        
        modelContext.insert(wine)
        
        var remainingQuantites = quantitiesByYear
        for quantity in quantities.filter({ $0.id == wine.id }) {
            if let newQuantity = quantitiesByYear[quantity.year] {
                quantity.quantity = newQuantity
                quantity.price = pricesByYear[quantity.year] ?? 0
            } else {
                modelContext.delete(quantity)
            }
            remainingQuantites.removeValue(forKey: quantity.year)
        }
        for (year, quantity) in remainingQuantites {
            modelContext.insert(Quantity(id: wine.id,
                                         year: year,
                                         quantity: quantity,
                                         price: pricesByYear[year] ?? 0))
        }
        try? modelContext.save()
    }
    
    func quantity(for wine: Wine) -> Int {
        var result = 0
        for quantity in quantities.filter({ $0.id == wine.id }) {
            result += quantity.quantity
        }
        return result
    }
}
