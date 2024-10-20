//
//  View+extensions.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 28/09/2024.
//

import SwiftUI

extension View {
    func addLinearGradientBackground() -> some View {
        background(
            VStack {
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.8), .clear]),
                               startPoint: .top,
                               endPoint: .bottom)
                .frame(height: 200)
                .ignoresSafeArea(edges: .top)
                Spacer()
            }
        )
    }
    
    func loader(isPresented: Binding<Bool>) -> some View {
        ModifiedContent(content: self, modifier: LoaderViewModifier(isPresented: isPresented))
    }
}
