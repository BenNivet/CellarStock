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
    
    var body: some View {
        VStack(spacing: CharterConstants.margin) {
            Text("Félicitations")
                .font(.title)
            Text("Acceptez vous cette proposition ?")
                .font(.title3)
            Spacer()
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
            VStack(spacing: CharterConstants.marginSmall) {
                Button {
                    quantity.quantity -= 1
                    if quantity.quantity == 0 {
                        modelContext.delete(quantity)
                    }
                    if quantity(for: wine) == 0 {
                        modelContext.delete(wine)
                    }
                    try? modelContext.save()
                    dismiss()
                } label: {
                    Text("Oui")
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 40)
                .buttonStyle(.borderedProminent)
                Button {
                    dismiss()
                } label: {
                    Text("Non, rejouer")
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 40)
                .buttonStyle(.bordered)
                
            }
        }
        .padding(CharterConstants.margin)
    }
}

private extension CongratsView {
    func quantity(for wine: Wine) -> Int {
        var result = 0
        for quantity in quantities.filter({ $0.id == wine.id }) {
            result += quantity.quantity
        }
        return result
    }
}
