//
//  SwiftUIView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 07/12/2023.
//

import SwiftUI

struct NeoTabsStaticItemsView: View {
    let items: [NeoTabsItemModel]
    @Binding var selectedIndex: Int
    let contentWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                NeoTabsItemView(item: item,
                                isSelected: item.index == selectedIndex) { selectedIndex = item.index }
                .frame(width: contentWidth / CGFloat(items.count))
            }
        }
    }
}
