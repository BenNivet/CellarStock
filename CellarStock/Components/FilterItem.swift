//
//  FilterItem.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 12/11/2023.
//

import SwiftUI

enum FilterType {
    case region
    case type
    case year
    
    var label: String {
        switch self {
        case .region:
            "Régions"
        case .type:
            "Types"
        case .year:
            "Années"
        }
    }
}

struct FilterItem: View {
    
    @State private var isPressed = false
    let type: FilterType
    @Binding var filteringElements: [Int]
    @State private var showingSheet = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body.bold())
                .foregroundStyle(filteringElements.isEmpty ? .white : .black)
            if !filteringElements.isEmpty {
                Image(systemName: "xmark")
                    .font(.body.bold())
                    .foregroundStyle(.black)
                    .onTapGesture {
                        filteringElements.removeAll()
                    }
            } else {
                Image(systemName: "chevron.down")
                    .font(.body.bold())
                    .foregroundStyle(.white)
            }
        }
        .onTapGesture {
            showingSheet = true
        }
        .onLongPressGesture(minimumDuration: .infinity,
                            maximumDistance: .infinity) {
            isPressed = true
        } onPressingChanged: { state in
            isPressed = state
        }
        .padding()
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radius))
        .sheet(isPresented: $showingSheet) {
            SelectionListView(type: type, filteringElements: $filteringElements)
        }
    }
    
    private var label: String {
        if filteringElements.isEmpty {
            type.label
        } else if filteringElements.count == 1,
                  let index = filteringElements.first {
            switch type {
            case .region:
                Region(rawValue: index)?.description ?? type.label
            case .type:
                WineType(rawValue: index)?.description ?? type.label
            case .year:
                String(index)
            }
        } else {
            "\(type.label) . \(filteringElements.count)"
        }
        
    }
    
    private var backgroundColor: Color {
        if filteringElements.isEmpty {
            if isPressed {
                .black.opacity(0.5)
            } else {
                .black
            }
        } else {
            if isPressed {
                .white.opacity(0.8)
            } else {
                .white
            }
        }
    }
}
