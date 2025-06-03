//
//  DataManager.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 18/11/2024.
//

import Combine

final class DataManager: ObservableObject {
    @Published var wines: [Wine] = []
    @Published var quantities: [Quantity] = []

    func reset() {
        wines.removeAll()
        quantities.removeAll()
    }
}
