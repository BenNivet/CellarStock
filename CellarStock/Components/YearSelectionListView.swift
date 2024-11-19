//
//  YearSelectionListView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 21/11/2023.
//

import SwiftUI

struct YearSelectionListView: View {
    
    let availableYears: [Int]
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var quantities: [Int: Int]
    @Binding var prices: [Int: Double]
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                listRows
            }
            .listStyle(.plain)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher")
            .keyboardType(.numberPad)
            .navigationTitle("Année")
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
    var listRows: some View {
        let filteredItems = searchText.isEmpty ? availableYears : availableYears.filter { String($0).localizedCaseInsensitiveContains(searchText) }
        ForEach(filteredItems, id: \.self) { year in
            Button {
                quantities[year] = 1
                prices[year] = 0
                dismiss()
            } label: {
                if year == CharterConstants.withoutYear {
                    Text("Sans millésime")
                } else {
                    Text(String(year))
                }
            }
        }
    }
}
