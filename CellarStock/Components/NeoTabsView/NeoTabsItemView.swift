//
//  NeoTabsItemView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 07/12/2023.
//

import SwiftUI

public struct NeoTabsItemView: View {
    let item: NeoTabsItemModel
    let isSelected: Bool
    let selection: () -> ()
    
    public init(item: NeoTabsItemModel, isSelected: Bool, selection: @escaping () -> ()) {
        self.item = item
        self.isSelected = isSelected
        self.selection = selection
    }
    
    public var body: some View {
        Button {
            selection()
        } label: {
            VStack(spacing: CharterConstants.marginSmall) {
                Text(item.title)
                    .font(.headline)
                    .bold()
                Rectangle()
                    .fill(underLineColor)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var underLineColor: Color {
        isSelected ? .white : .clear
    }
}
