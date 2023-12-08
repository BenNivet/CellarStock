//
//  TileView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 01/11/2023.
//

import SwiftUI

struct TileView<Content: View>: View {
    
    @ViewBuilder var component: () -> Content
    @State private var isPressed = false
    let action: ActionClosure?
    
    init(@ViewBuilder component: @escaping () -> Content,
         action: (() -> Void)? = nil) {
        self.component = component
        self.action = ActionClosure(handler: action ?? {})
    }
    
    var body: some View {
        HStack(spacing: 0) {
            component()
                .padding(CharterConstants.margin)
        }
        .background(backgroundColor(isPressed: isPressed))
        .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radiusSmall))
        .onTapGesture {
            action?.handler()
        }
        .onLongPressGesture(minimumDuration: .infinity,
                            maximumDistance: .infinity) {
            isPressed = true
        } onPressingChanged: { state in
            isPressed = state
        }
    }
}

private extension TileView {
    func backgroundColor(isPressed: Bool) -> Color {
        isPressed ? .gray.opacity(CharterConstants.alphaThirty) : .gray.opacity(CharterConstants.alphaFifteen)
    }
}
