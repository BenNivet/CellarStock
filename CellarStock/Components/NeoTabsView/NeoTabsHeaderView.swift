//
//  NeoTabsHeaderView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 07/12/2023.
//

import SwiftUI

public struct NeoTabsHeaderView: View {
    let items: [NeoTabsItemModel]
    @Binding var selectedIndex: Int
    let width: CGFloat
    
    public init(items: [NeoTabsItemModel], selectedIndex: Binding<Int>, width: CGFloat) {
        self.items = items
        _selectedIndex = selectedIndex
        self.width = width
    }
    
    public var body: some View {
        ZStack {
            if items.count > 3 {
                NeoTabsDynamicItemsView(items: items,
                                        selectedIndex: $selectedIndex)
            } else {
                NeoTabsStaticItemsView(items: items,
                                       selectedIndex: $selectedIndex,
                                       contentWidth: width)
            }
        }
    }
}
