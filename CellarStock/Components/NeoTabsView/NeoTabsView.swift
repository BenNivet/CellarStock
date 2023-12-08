//
//  NeoTabsView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 07/12/2023.
//

import SwiftUI

public struct NeoTabsView: View {
    let items: [NeoTabsItemModel]
    @State private var selectedIndex = 0
    
    public init(items: [NeoTabsItemModel], selectedIndex: Int = 0) {
        self.items = items
        _selectedIndex = .init(wrappedValue: selectedIndex)
    }
    
    public var body: some View {
        GeometryReader { reader in
            VStack(spacing: 0) {
                NeoTabsHeaderView(items: items,
                                  selectedIndex: $selectedIndex,
                                  width: reader.size.width)
                NeoTabsContentView(items: items,
                                   selectedIndex: $selectedIndex)
            }
        }
    }
}
