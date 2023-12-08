//
//  NeoTabsDynamicItemsView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 07/12/2023.
//

import SwiftUI

struct NeoTabsDynamicItemsView: View {
    let items: [NeoTabsItemModel]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CharterConstants.margin) {
                    ForEach(items) { item in
                        NeoTabsItemView(item: item,
                                        isSelected: item.index == selectedIndex) {
                            selectedIndex = item.index
                            proxy.scrollTo(item.index, anchor: nil)
                        }.id(item.index)
                    }
                }
                .padding(.horizontal, CharterConstants.margin)
                .onChange(of: selectedIndex, {
                    proxy.scrollTo(selectedIndex, anchor: nil)
                })
            }
        }
    }
}
