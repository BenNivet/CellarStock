//
//  ChipModel.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 23/10/2024.
//

import SwiftUI

public struct ChipModel: Identifiable {
    public let id = UUID()
    @Binding var isActive: Bool
    let title: String
    let state: ChipState

    public init(isActive: Binding<Bool>,
                title: String,
                state: ChipState = .defaultState) {
        _isActive = isActive
        self.title = title
        self.state = state
    }
}

public enum ChipState {
    case defaultState
    case disabled
}
