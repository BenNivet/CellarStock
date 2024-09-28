//
//  View+extensions.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 28/09/2024.
//

import SwiftUI

extension View {
    
    func addLinearGradientBackground() -> some View {
        ZStack(alignment: .top) {
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.8), .clear]),
                           startPoint: .top,
                           endPoint: .bottom)
            .frame(height: 200)
            .edgesIgnoringSafeArea(.all)
            
            self
        }
    }
}
