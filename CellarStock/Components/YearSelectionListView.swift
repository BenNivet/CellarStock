//
//  YearSelectionListView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 21/11/2023.
//

import SwiftUI

struct YearSelectionListView: View {
    
    let availableYears: [Int]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Binding var quantities: [Int: Int]
    @Binding var prices: [Int: Double]
    
    var body: some View {
        ScrollView {
            VStack(spacing: CharterConstants.marginSmall) {
                ForEach(availableYears, id: \.self) { year in
                    TileView {
                        Text(String(year))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } action: {
                        quantities[year] = 1
                        prices[year] = 0
                        dismiss()
                    }
                }
            }
            .padding(CharterConstants.margin)
        }
    }
}
