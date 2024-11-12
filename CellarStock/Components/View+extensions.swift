//
//  View+extensions.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 28/09/2024.
//

import SwiftUI

extension View {
    
    var closeButtonView: some View {
        Image(systemName: "xmark")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(.white)
            .clipShape(Circle())
    }
    
    func requiredAttributedText(opacity: Double = 1) ->AttributedString {
        var requiredText = AttributedString("(\(String(localized: "requis")))")
        requiredText.foregroundColor = CharterConstants.mainRed.opacity(opacity)
        return requiredText
    }
    
    func addLinearGradientBackground() -> some View {
        background(
            VStack {
                LinearGradient(gradient: Gradient(colors: [CharterConstants.mainBlue.opacity(0.8), .clear]),
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
    
    func bordered() -> some View {
        overlay(RoundedRectangle(cornerRadius: CharterConstants.radius)
            .stroke(.gray, lineWidth: 1))
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
