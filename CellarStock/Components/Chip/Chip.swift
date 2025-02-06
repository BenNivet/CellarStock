//
//  Chip.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 23/10/2024.
//

import SwiftUI

public struct Chip: View {
    let model: ChipModel

    public init(model: ChipModel) {
        self.model = model
    }

    public var body: some View {
        Text(model.title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, CharterConstants.margin)
            .frame(height: CharterConstants.marginBig)
            .background(
                Capsule()
                    .strokeBorder(strokeColor, lineWidth: strokeWidth)
                    .background(Capsule().foregroundColor(backgroundColor))
                    .shadow(color: .black.opacity(0.05), radius: CharterConstants.radius, x: 0, y: 0)
            )
            .clipShape(Capsule())
            .onTapGesture {
                model.isActive.toggle()
            }
    }
}

private extension Chip {

    var strokeColor: Color {
        if model.state == .disabled {
            .white.opacity(CharterConstants.disabledOpacity)
        } else if model.isActive {
            .white
        } else {
            .white
        }
    }

    var strokeWidth: CGFloat {
        if model.isActive {
            1
        } else {
            0.5
        }
    }

    var backgroundColor: Color {
        if model.state == .disabled {
            .black.opacity(CharterConstants.disabledOpacity)
        } else if model.isActive {
            .white
        } else {
            .black
        }
    }
    
    var foregroundColor: Color {
        if model.state == .disabled {
            .white.opacity(CharterConstants.disabledOpacity)
        } else if model.isActive {
            .black
        } else {
            .white
        }
    }
}
