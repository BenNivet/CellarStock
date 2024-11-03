//
//  FormView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import Combine
import FirebaseAnalytics
import Foundation
import StoreKit
import SwiftUI
import SwiftData
import VisionKit

enum WinePicker {
    case region
    case appelation
    case type
}

@MainActor
struct FormView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
    @EnvironmentObject private var entitlementManager: EntitlementManager
    
    @Query private var users: [User]
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
    @State private var selectedYearAmount = 0
    @State private var showingDeleteAlert = false
    @State private var sensorFeedback = false
    
    private let listener = PassthroughSubject<Bool,Never>()
    private let firestoreManager = FirestoreManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                formView
                Spacer()
                VStack(spacing: CharterConstants.margin) {
                    Button("Sauvegarder") {
                        save()
                        dismiss()
                        sensorFeedback = true
                        Analytics.logEvent(wine.wineId.isEmpty ? LogEvent.addWine : LogEvent.updateWine, parameters: nil)
                        entitlementManager.winesSubmitted += 1
                        if subscriptionsManager.needRating {
                            requestReview()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(wine.name.isEmpty || (wine.wineId.isEmpty && quantitiesByYear.isEmpty))
                    
                    if !wine.wineId.isEmpty {
                        Button("Supprimer") {
                            showingDeleteAlert = true
                        }
                        .buttonStyle(DestructiveButtonStyle())
                    }
                }
                .padding(CharterConstants.margin)
            }
            .addLinearGradientBackground()
            .keyboardAvoiding()
            .scrollIndicators(.hidden)
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Ajouter un vin")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        closeButtonView
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var formView: some View {
        VStack(spacing: CharterConstants.margin) {
            if !showQuantitiesOnly {
                section("Caractéristiques")
                
                FloatingTextField(type: .picker(rows: Region.allCases.map { $0.description }),
                                  placeHolder: "Région",
                                  text: pickerValueBinding(wine.region, type: .region),
                                  rightIcon: "chevron.right")
                if wine.region == .bordeaux {
                    FloatingTextField(type: .picker(rows: Appelation.allCases.sorted { $0.description < $1.description }.map { $0.description }),
                                      placeHolder: "Appelation",
                                      text: pickerValueBinding(wine.appelation, type: .appelation),
                                      rightIcon: "chevron.right")
                }
                FloatingTextField(type: .picker(rows: WineType.allCases.map { $0.description }),
                                  placeHolder: "Type",
                                  text: pickerValueBinding(wine.type, type: .type),
                                  rightIcon: "chevron.right")
                FloatingTextField(placeHolder: "Nom",
                                  text: $wine.name,
                                  isRequired: true,
                                  rightIcon: scannerAvailable ? "camera" : nil) {
                    hideKeyboard()
                    showingCameraSheet = true
                }
            }
            
            section("Années", isRequired: wine.wineId.isEmpty && quantitiesByYear.isEmpty)
            
            ForEach(quantitiesByYear.keys.sorted(by: >), id: \.self) { year in
                HStack(spacing: CharterConstants.margin) {
                    ZStack {
                        Text(year == CharterConstants.withoutYear ? "Ø" : String(year))
                        Text("XXXX")
                            .layoutPriority(1)
                            .opacity(0)
                    }
                    .font(.system(size: 18))
                    
                    Divider()
                        .frame(width: 0.5)
                        .background(CharterConstants.halfWhite)
                    
                    VStack(spacing: CharterConstants.margin) {
                        HStack {
                            Text("Quantités")
                            Spacer()
                            AnimatedStepper(currentNumber: quantitiesByYear[year] ?? 0) {
                                quantitiesByYear[year] = (quantitiesByYear[year] ?? 0) + 1
                            } onDecrement: {
                                guard let quantity = quantitiesByYear[year] else { return }
                                if quantity > 1 {
                                    quantitiesByYear[year] = (quantity - 1)
                                } else {
                                    withAnimation {
                                        quantitiesByYear[year] = nil
                                    }
                                }
                            }
                        }
                        HStack {
                            Text("Prix")
                            Spacer()
                            Text("\(String(Int(pricesByYear[year] ?? 0))) €")
                        }
                        .onTapGesture {
                            hideKeyboard()
                            selectedYearAmount = year
                        }
                    }
                }
                .padding(.bottom, CharterConstants.marginSmall)
                .overlay(alignment: .bottom) {
                    Divider()
                        .frame(height: 0.5)
                        .background(CharterConstants.halfWhite)
                }
            }
            
            Button {
                hideKeyboard()
                showingSheet = true
            } label: {
                HStack(spacing: CharterConstants.marginSmall) {
                    Image(systemName: "plus.circle")
                    Text("Ajouter une année")
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            
            if !showQuantitiesOnly {
                section("Autres informations")
                
                FloatingTextField(placeHolder: "Vigneron / Domaine", text: $wine.owner)
                FloatingTextField(placeHolder: "Infos / Étage clayette", text: $wine.info)
            }
        }
        .padding(CharterConstants.margin)
        .sheet(isPresented: bindingScannedText) {
            NavigationView {
                let linesText = scannedText.components(separatedBy: "\n")
                List {
                    ForEach(linesText, id: \.self) { lineText in
                        Button {
                            wine.name = lineText
                            scannedText = ""
                        } label: {
                            Text(lineText)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Nom du vin")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            scannedText.removeAll()
                        } label: {
                            closeButtonView
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingSheet) {
            YearSelectionListView(
                availableYears: Helper.shared.availableYears(for: wine,
                                                             selectedYears: Array(quantitiesByYear.keys)),
                quantities: $quantitiesByYear,
                prices: $pricesByYear
            )
        }
        .sheet(isPresented: $showingCameraSheet) {
            ZStack(alignment: .bottom) {
                DocumentScannerView(selectedText: $scannedText, listener: listener)
                    .ignoresSafeArea()
                    .analyticsScreen(name: ScreenName.scanWine, class: ScreenName.scanWine)
                Button("") {
                    listener.send(true)
                }
                .buttonStyle(CameraButtonStyle())
                .padding(.horizontal, CharterConstants.margin)
                .padding(.bottom, CharterConstants.margin)
            }
        }
        .fullScreenCover(isPresented: bindingAmount) {
            AmountView(year: $selectedYearAmount, pricesByYear: $pricesByYear)
                .analyticsScreen(name: ScreenName.addWinePrice, class: ScreenName.addWinePrice)
        }
        .alert("Voulez vous supprimer ce vin ?", isPresented: $showingDeleteAlert) {
            Button("Oui", role: .destructive) {
                quantitiesByYear.removeAll()
                save()
                dismiss()
                sensorFeedback = true
                Analytics.logEvent(LogEvent.deleteWine, parameters: nil)
            }
            Button("Annuler", role: .cancel) {}
        }
        .sensoryFeedback(.success, trigger: sensorFeedback)
    }
    
    func section(_ title: String, isRequired: Bool = false) -> some View {
        var text = AttributedString(title)
        text.foregroundColor = .white
        
        return Text(isRequired ? text + " " + requiredAttributedText(opacity: 0.8) : text)
            .font(.system(size: 23, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.top, CharterConstants.margin)
    }
}

private extension FormView {
    
    var scannerAvailable: Bool {
        DataScannerViewController.isSupported &&
        DataScannerViewController.isAvailable
    }
    
    var bindingScannedText: Binding<Bool> {
        Binding { !scannedText.isEmpty } set: { _ in }
    }
    
    var bindingAmount: Binding<Bool> {
        Binding { selectedYearAmount != 0 } set: { _ in }
    }
    
    func pickerValueBinding(_ value: CustomStringConvertible, type: WinePicker) -> Binding<String> {
        Binding {
            String(describing: value)
        } set: { newValue in
            switch type {
            case .region:
                guard let region = Region.allCases.first(where: { $0.description == newValue })
                else { return }
                wine.region = region
            case .appelation:
                guard let appelation = Appelation.allCases.first(where: { $0.description == newValue })
                else { return }
                wine.appelation = appelation
            case .type:
                guard let type = WineType.allCases.first(where: { $0.description == newValue })
                else { return }
                wine.type = type
            }
        }
    }
    
    func save() {
        Task {
            guard !quantitiesByYear.isEmpty else {
                for quantity in quantities where quantity.wineId == wine.wineId {
                    modelContext.delete(quantity)
                    await firestoreManager.deleteQuantity(quantity)
                }
                try? modelContext.save()
                if wines.contains(wine) {
                    modelContext.delete(wine)
                    await firestoreManager.deleteWine(wine)
                }
                try? modelContext.save()
                return
            }
            
            if let user = users.first {
                wine.userId = user.documentId
            } else {
                let resultId = await firestoreManager.createUser()
                if let resultId {
                    modelContext.insert(User(documentId: resultId))
                    try? modelContext.save()
                    wine.userId = resultId
                }
            }
            
            guard !wine.userId.isEmpty else { return }
            let wineId = await firestoreManager.insertOrUpdateWine(wine)
            guard let wineId else { return }
            wine.wineId = wineId
            modelContext.insert(wine)
            
            var remainingQuantites = quantitiesByYear
            for quantity in quantities where quantity.wineId == wine.wineId {
                if let newQuantity = quantitiesByYear[quantity.year] {
                    quantity.quantity = newQuantity
                    quantity.price = pricesByYear[quantity.year] ?? 0
                    await firestoreManager.updateQuantity(quantity)
                } else {
                    modelContext.delete(quantity)
                    await firestoreManager.deleteQuantity(quantity)
                }
                remainingQuantites.removeValue(forKey: quantity.year)
            }
            
            for (year, quantity) in remainingQuantites {
                let newQuantity = Quantity(userId: wine.userId,
                                           wineId: wineId,
                                           year: year,
                                           quantity: quantity,
                                           price: pricesByYear[year] ?? 0)
                let documentId = await firestoreManager.insertQuantity(newQuantity)
                if let documentId {
                    newQuantity.documentId = documentId
                    modelContext.insert(newQuantity)
                }
            }
            
            try? modelContext.save()
        }
    }
    
    func quantity(for wine: Wine) -> Int {
        var result = 0
        for quantity in quantities where quantity.wineId == wine.wineId {
            result += quantity.quantity
        }
        return result
    }
}
