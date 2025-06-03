//
//  FormView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import Combine
import FirebaseAnalytics
import Foundation
import PhotosUI
import StoreKit
import SwiftData
import SwiftUI
import Vision
import VisionKit

enum WinePicker {
    case country
    case region
    case appelation
    case usAppelation
    case type
    case size
}

struct FormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview

    @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var dataManager: DataManager

    @Binding var wine: Wine
    @Binding var quantitiesByYear: [Int: Int]
    @Binding var pricesByYear: [Int: Double]
    @Binding var showQuantitiesOnly: Bool

    @State private var showingSheet = false
    @State private var showingActionSheet = false
    @State private var showingCameraSheet = false
    @State private var showingPhotoPicker = false
    @State private var scannedText = ""
    @State private var selectedYearAmount = 0
    @State private var showingDeleteAlert = false
    @State private var sensorFeedback = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    private let listener = PassthroughSubject<Bool, Never>()
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

    @ViewBuilder private var formView: some View {
        VStack(spacing: CharterConstants.margin) {
            if !showQuantitiesOnly {
                section(String(localized: "Caractéristiques"))

                FloatingTextField(type: .picker(rows: Country.allCases.map(\.description)),
                                  placeHolder: String(localized: "Pays"),
                                  text: pickerValueBinding(wine.country, type: .country),
                                  rightIcon: "chevron.right")

                if wine.country == .france {
                    FloatingTextField(type: .picker(rows: Region.allCases.map(\.description)),
                                      placeHolder: String(localized: "Région"),
                                      text: pickerValueBinding(wine.region, type: .region),
                                      rightIcon: "chevron.right")
                    if wine.region == .bordeaux {
                        FloatingTextField(type: .picker(rows: Appelation.allCases.sorted { $0.description < $1.description }
                                              .map(\.description)),
                        placeHolder: String(localized: "Appelation"),
                        text: pickerValueBinding(wine.appelation, type: .appelation),
                        rightIcon: "chevron.right")
                    }
                } else if wine.country == .usa {
                    FloatingTextField(type: .picker(rows: USAppelation.allCases.sorted { $0.description < $1.description }
                                          .map(\.description)),
                    placeHolder: String(localized: "Appelation"),
                    text: pickerValueBinding(wine.usAppelation, type: .usAppelation),
                    rightIcon: "chevron.right")
                }
                FloatingTextField(type: .picker(rows: WineType.allCases.map(\.description)),
                                  placeHolder: String(localized: "Type"),
                                  text: pickerValueBinding(wine.type, type: .type),
                                  rightIcon: "chevron.right")
                FloatingTextField(type: .picker(rows: Size.allCases.map(\.description)),
                                  placeHolder: String(localized: "Taille"),
                                  text: pickerValueBinding(wine.size, type: .size),
                                  rightIcon: "chevron.right")
                FloatingTextField(placeHolder: String(localized: "Nom"),
                                  text: $wine.name,
                                  isRequired: true,
                                  rightIcon: scannerAvailable ? "camera" : nil) {
                    hideKeyboard()
                    showingActionSheet = true
                }
            }

            section(String(localized: "Millésimes"), isRequired: wine.wineId.isEmpty && quantitiesByYear.isEmpty)

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
                            Text("Qté")
                            Spacer()
                            HStack(spacing: CharterConstants.margin) {
                                AnimatedStepper(currentNumber: bindingQuantity(year: year)) {
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

                                if !showQuantitiesOnly {
                                    Button("+6") {
                                        guard let quantity = quantitiesByYear[year] else { return }
                                        withAnimation(.linear) {
                                            quantitiesByYear[year] = if quantity == 1 {
                                                6
                                            } else {
                                                quantity + 6
                                            }
                                        }
                                    }
                                    .buttonStyle(CircleButtonStyle())
                                }
                            }
                        }
                        HStack {
                            Text("Prix")
                            Spacer()
                            Text("\(String(Int(pricesByYear[year] ?? 0))) \(String(describing: Locale.current.currencySymbol ?? "€"))")
                                .opacity(pricesByYear[year] ?? 0 > 0 ? 1 : 0.6)
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
                    Text("Ajouter un millésime")
                }
            }
            .buttonStyle(SecondaryButtonStyle())

            if !showQuantitiesOnly {
                section(String(localized: "Autres informations"))

                FloatingTextField(placeHolder: String(localized: "Vigneron / Domaine"), text: $wine.owner)
                FloatingTextField(placeHolder: String(localized: "Infos / Étage clayette"), text: $wine.info)
            }
        }
        .padding(CharterConstants.margin)
        .onChange(of: selectedPhoto, processPhoto)
        .onChange(of: selectedImage, processImage)
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
            .analyticsScreen(name: ScreenName.selectWineName, class: ScreenName.selectWineName)
        }
        .sheet(isPresented: $showingSheet) {
            YearSelectionListView(availableYears: Helper.shared.availableYears(for: wine,
                                                                               selectedYears: Array(quantitiesByYear.keys)),
                                  quantities: $quantitiesByYear,
                                  prices: $pricesByYear)
                .analyticsScreen(name: ScreenName.yearList, class: ScreenName.yearList)
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
        .photosPicker(isPresented: $showingPhotoPicker,
                      selection: $selectedPhoto)
        .fullScreenCover(isPresented: bindingAmount) {
            AmountView(year: $selectedYearAmount, pricesByYear: $pricesByYear)
                .analyticsScreen(name: ScreenName.addWinePrice, class: ScreenName.addWinePrice)
        }
        .confirmationDialog("", isPresented: $showingActionSheet) {
            Button {
                showingCameraSheet = true
            } label: {
                Text("Prendre une photo")
            }
            Button {
                showingPhotoPicker = true
            } label: {
                Text("Photothèque")
            }
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

    func bindingQuantity(year: Int) -> Binding<Int> {
        Binding {
            quantitiesByYear[year] ?? 0
        } set: { newValue in
            quantitiesByYear[year] = newValue
        }
    }

    func pickerValueBinding(_ value: CustomStringConvertible, type: WinePicker) -> Binding<String> {
        Binding {
            String(describing: value)
        } set: { newValue in
            switch type {
            case .country:
                guard let country = Country.allCases.first(where: { $0.description == newValue })
                else { return }
                wine.country = country
            case .region:
                guard let region = Region.allCases.first(where: { $0.description == newValue })
                else { return }
                wine.region = region
            case .appelation:
                guard let appelation = Appelation.allCases.first(where: { $0.description == newValue })
                else { return }
                wine.appelation = appelation
            case .usAppelation:
                guard let usAppelation = USAppelation.allCases.first(where: { $0.description == newValue })
                else { return }
                wine.usAppelation = usAppelation
            case .type:
                guard let type = WineType.allCases.first(where: { $0.description == newValue })
                else { return }
                wine.type = type
            case .size:
                guard let size = Size.allCases.first(where: { $0.description == newValue })
                else { return }
                wine.size = size
            }
        }
    }

    func save() {
        Task {
            guard !quantitiesByYear.isEmpty else {
                for quantity in dataManager.quantities where quantity.wineId == wine.wineId {
                    if let index = dataManager.quantities.firstIndex(of: quantity) {
                        dataManager.quantities.remove(at: index)
                    }
                    firestoreManager.deleteQuantity(quantity)
                }
                if dataManager.wines.contains(wine) {
                    if let index = dataManager.wines.firstIndex(of: wine) {
                        dataManager.wines.remove(at: index)
                    }
                    firestoreManager.deleteWine(wine)
                }
                return
            }

            if let userId = entitlementManager.userId {
                wine.userId = userId
            } else {
                let resultId = await firestoreManager.createUser()
                if let resultId {
                    entitlementManager.userId = resultId
                    wine.userId = resultId
                }
            }

            guard !wine.userId.isEmpty else { return }
            let wineId = await firestoreManager.insertOrUpdateWine(wine)
            guard let wineId else { return }
            wine.wineId = wineId
            if let index = dataManager.wines.firstIndex(of: wine) {
                dataManager.wines.remove(at: index)
            }
            dataManager.wines.append(wine)

            var remainingQuantites = quantitiesByYear
            for quantity in dataManager.quantities where quantity.wineId == wine.wineId {
                if let newQuantity = quantitiesByYear[quantity.year] {
                    quantity.quantity = newQuantity
                    quantity.price = pricesByYear[quantity.year] ?? 0
                    firestoreManager.updateQuantity(quantity)
                } else {
                    if let index = dataManager.quantities.firstIndex(of: quantity) {
                        dataManager.quantities.remove(at: index)
                    }
                    firestoreManager.deleteQuantity(quantity)
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
                    newQuantity.quantityId = documentId
                    dataManager.quantities.append(newQuantity)
                }
            }
        }
    }

    func quantity(for wine: Wine) -> Int {
        var result = 0
        for quantity in dataManager.quantities where quantity.wineId == wine.wineId {
            result += quantity.quantity
        }
        return result
    }

    private func processPhoto() {
        guard let selectedPhoto else { return }
        Task {
            if let data = try? await selectedPhoto.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
                self.selectedPhoto = nil
            } else {
                self.selectedPhoto = nil
            }
        }
    }

    private func processImage() {
        guard let image = selectedImage?.cgImage else { return }
        let request = VNRecognizeTextRequest { request, _ in
            if let results = request.results as? [VNRecognizedTextObservation] {
                let lines = results.compactMap { $0.topCandidates(1).first?.string }
                scannedText = Helper().formatArrayWineName(lines: lines)
            }
        }

        let imageRequestHandler = VNImageRequestHandler(cgImage: image)
        try? imageRequestHandler.perform([request])
    }
}
