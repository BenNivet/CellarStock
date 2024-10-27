//
//  CameraButtonStyle.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 23/10/2024.
//

import SwiftUI

struct CameraButtonStyle: ButtonStyle {
    
    private let size: CGFloat = 75
    private let whiteSpace: CGFloat = 5
    private let blackSpace: CGFloat = 7
    private let pressSpace: CGFloat = 10
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .frame(width: size, height: size)
            .overlay {
                Circle()
                    .fill(Color.clear)
                    .stroke(Color.white, lineWidth: whiteSpace)
                    .frame(width: size)
            }
            .overlay {
                Circle()
                    .fill(Color.white)
                    .frame(width: size - whiteSpace - blackSpace - (configuration.isPressed ? pressSpace : 0))
            }
    }
}
