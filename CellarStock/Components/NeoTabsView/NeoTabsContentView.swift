//
//  NeoTabsContentView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 07/12/2023.
//

import SwiftUI

public struct NeoTabsContentView: View {
    let items: [NeoTabsItemModel]
    @Binding var selectedIndex: Int

    public init(items: [NeoTabsItemModel], selectedIndex: Binding<Int>) {
        self.items = items
        _selectedIndex = selectedIndex
    }
    
    public var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(items) { item in
                item.content()
                    .tag(item.index)
            }
        }.setPageMode()
    }
}

private extension View {
    func setPageMode() -> some View {
        tabViewStyle(.page(indexDisplayMode: .never))
    }
}
