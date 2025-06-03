//
//  CongratsView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 01/11/2023.
//

import SwiftData
import SwiftUI

struct CongratsView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject private var dataManager: DataManager

    @Binding var wine: Wine
    @Binding var quantity: Quantity

    private let firestoreManager = FirestoreManager.shared

    var body: some View {
        VStack(spacing: CharterConstants.margin) {
            Text("Félicitations")
                .font(.title)
                .padding(.top, CharterConstants.margin)
            Text("Acceptez vous cette proposition ?")
                .font(.title3)
                .padding(.bottom, CharterConstants.margin)
            TileView {
                HStack {
                    VStack(alignment: .leading) {
                        if wine.size != .bouteille {
                            Text(wine.name + " (\(wine.size.description.components(separatedBy: " ").first ?? ""))")
                                .font(.body)
                        } else {
                            Text(wine.name)
                                .font(.body)
                        }
                        if wine.country == .france {
                            Text(wine.region.description)
                                .font(.caption)
                            if wine.region == .bordeaux, wine.appelation != .other {
                                Text(wine.appelation.description)
                                    .font(.caption)
                            }
                        } else {
                            Text(wine.country.description)
                                .font(.caption)
                            if wine.country == .usa, wine.usAppelation != .other {
                                Text(wine.usAppelation.description)
                                    .font(.caption)
                            }
                        }
                        Text(wine.type.description)
                            .font(.caption)
                        if !wine.owner.isEmpty {
                            Text(wine.owner)
                                .font(.caption)
                        }
                        Text(quantity.year == CharterConstants.withoutYear ? String(localized: "Sans millésime") : String(quantity.year))
                            .font(.caption)
                        Text(quantity.quantity.bottlesString)
                            .font(.caption)
                    }
                    Spacer()
                }
            }
            Spacer()
            VStack(spacing: CharterConstants.margin) {
                Button("Oui") {
                    quantity.quantity -= 1
                    Task {
                        if quantity.quantity == 0 {
                            if let index = dataManager.quantities.firstIndex(of: quantity) {
                                dataManager.quantities.remove(at: index)
                            }
                            firestoreManager.deleteQuantity(quantity)
                        } else {
                            firestoreManager.updateQuantity(quantity)
                        }

                        if quantity(for: wine) == 0 {
                            if let index = dataManager.wines.firstIndex(of: wine) {
                                dataManager.wines.remove(at: index)
                            }
                            firestoreManager.deleteWine(wine)
                        } else {
                            if let index = dataManager.wines.firstIndex(of: wine) {
                                dataManager.wines.remove(at: index)
                            }
                            dataManager.wines.append(wine)
                        }
                    }
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("Non, rejouer") {
                    dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(CharterConstants.margin)
    }
}

private extension CongratsView {
    func quantity(for wine: Wine) -> Int {
        var result = 0
        for quantity in dataManager.quantities where quantity.wineId == wine.wineId {
            result += quantity.quantity
        }
        return result
    }
}
