//
//  SelectionListView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 12/11/2023.
//

import SwiftUI
import SwiftData

struct SelectionListView: View {
    
    let type: FilterType
    
    @Environment(\.dismiss) var dismiss
    @Query private var quantities: [Quantity]
    @Binding var filteringElements: [Int]
    @State private var initialFilteringElements: [Int] = []
    
    private var isApplyEnabled: Bool { initialFilteringElements != filteringElements }
    
    private var years: [Int] {
        Array(Set(quantities.compactMap { $0.year })).sorted(by: >)
    }
    
    init(type: FilterType, filteringElements: Binding<[Int]>) {
        self.type = type
        _filteringElements = filteringElements
        _initialFilteringElements = State(wrappedValue: filteringElements.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: CharterConstants.margin) {
            titleView
                .padding(.horizontal, CharterConstants.margin)
                .padding(.top, CharterConstants.margin)
                .padding(.bottom, CharterConstants.marginSmall)
            ScrollView {
                VStack(spacing: CharterConstants.marginSmall) {
                    itemsView
                }
                .padding(.horizontal, CharterConstants.margin)
                .padding(.bottom, CharterConstants.margin)
            }
        }
    }
    
    private var titleView: some View {
        HStack(spacing: CharterConstants.marginSmall) {
            Text(type.label)
                .font(.title2.bold())
            Spacer()
            if !initialFilteringElements.isEmpty {
                Text("Effacer")
                    .font(.body)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .padding(CharterConstants.marginSmall)
                    .background(.gray.opacity(CharterConstants.alphaThirty))
                    .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radiusSmall))
                    .onTapGesture {
                        initialFilteringElements = []
                    }
            }
            HStack {
                Text("Appliquer")
                    .font(.body.bold())
                    .foregroundStyle(.black)
                    .lineLimit(1)
                Image(systemName: "checkmark")
                    .font(.body.bold())
                    .foregroundStyle(.black)
            }
            .padding(CharterConstants.marginSmall)
            .background(isApplyEnabled ? .white : .gray.opacity(CharterConstants.disabledOpacity))
            .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radiusSmall))
            .onTapGesture {
                filteringElements = initialFilteringElements
                dismiss()
            }
            .disabled(!isApplyEnabled)
        }
    }
    
    @ViewBuilder
    private var itemsView: some View {
        switch type {
        case .region:
            ForEach(Region.allCases) { region in
                elementView(label: region.description, index: region.rawValue)
            }
        case .type:
            ForEach(WineType.allCases) { type in
                elementView(label: type.description, index: type.rawValue)
            }
        case .year:
            ForEach(years, id: \.self) { year in
                elementView(label: String(year), index: year)
            }
        }
    }
    
    private func elementView(label: String, index: Int) -> some View {
        TileView {
            Text(label)
            Spacer()
            image(for: index)
        } action: {
            if let indexToRemove = initialFilteringElements.firstIndex(of: index) {
                initialFilteringElements.remove(at: indexToRemove)
            } else {
                initialFilteringElements.append(index)
            }
        }
    }
    
    private func image(for index: Int) -> some View {
        if initialFilteringElements.contains(index) {
            Image(systemName: "checkmark.square.fill")
        } else {
            Image(systemName: "checkmark.square")
        }
    }
}
