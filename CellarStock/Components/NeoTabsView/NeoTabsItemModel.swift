//
//  NeoTabsItemModel.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 07/12/2023.
//

import SwiftUI

public struct NeoTabsItemModel: Identifiable {
    public var id: String { title }
    
    let title: String
    let index: Int
    let content: () -> AnyView
    
    public init(title: String, index: Int, content: @escaping () -> AnyView) {
        self.title = title
        self.content = content
        self.index = index
    }
}
