//
//  CongratsView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 01/11/2023.
//

import SwiftUI
import SwiftData

struct CongratsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query private var quantities: [Quantity]
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
                        Text(wine.name)
                            .font(.body)
                        Text(wine.region.description)
                            .font(.caption)
                        if wine.region == .bordeaux {
                            Text(wine.appelation.description)
                                .font(.caption)
                        }
                        Text(wine.type.description)
                            .font(.caption)
                        if !wine.owner.isEmpty {
                            Text(wine.owner)
                                .font(.caption)
                        }
                        Text(String(quantity.year))
                            .font(.caption)
                        Text(quantity.quantity.bottlesString)
                            .font(.caption)
                    }
                    Spacer()
                }
            }
            Spacer()
            VStack(spacing: CharterConstants.margin) {
                Button {
                    quantity.quantity -= 1
                    Task {
                        if quantity.quantity == 0 {
                            modelContext.delete(quantity)
                            await firestoreManager.deleteQuantity(quantity)
                        } else {
                            await firestoreManager.updateQuantity(quantity)
                        }
                        
                        if quantity(for: wine) == 0 {
                            modelContext.delete(wine)
                            await firestoreManager.deleteWine(wine)
                        }
                        try? modelContext.save()
                    }
                    dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: CharterConstants.radiusSmall)
                        .overlay {
                            Text("Oui")
                                .foregroundStyle(.white)
                                .font(.system(size: 16.5, weight: .semibold, design: .rounded))
                        }
                }
                .frame(height: 50)
                
                Button {
                    dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: CharterConstants.radiusSmall)
                        .fill(.gray.opacity(CharterConstants.alphaFifteen))
                        .overlay {
                            Text("Non, rejouer")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                }
                .frame(height: 50)
                
            }
        }
        .padding(CharterConstants.margin)
    }
}

private extension CongratsView {
    func quantity(for wine: Wine) -> Int {
        var result = 0
        for quantity in quantities where quantity.wineId == wine.wineId {
            result += quantity.quantity
        }
        return result
    }
}
