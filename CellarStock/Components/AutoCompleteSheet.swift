//
//  AutoCompleteSheet.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 23/10/2024.
//

import SwiftUI

struct AutoCompleteSheet: View {
    
    let title: String
    let rows: [String]
    
    @Binding var isPresented: Bool
    @Binding var value: String
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                autoCompleteListRows
            }
            .listStyle(.plain)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher")
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        closeButtonView
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var autoCompleteListRows: some View {
        let filteredItems = searchText.isEmpty ? rows : rows.filter { $0.localizedCaseInsensitiveContains(searchText) }
        ForEach(filteredItems, id: \.self) { item in
            Button {
                value = item
                searchText = ""
                isPresented = false
            } label: {
                Text(item)
            }
        }
    }
}
