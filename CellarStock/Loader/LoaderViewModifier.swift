//
//  LoaderViewModifier.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 14/10/2024.
//

import SwiftUI

public struct LoaderViewModifier: ViewModifier {
    @Binding var isPresented: Bool

    public init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }

    public func body(content: Content) -> some View {
        content
            .overlay(presentationView)
    }

    @ViewBuilder private var presentationView: some View {
        if isPresented {
            LoaderView()
                .transition(.opacity)
        }
    }
}
