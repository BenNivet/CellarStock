//
//  BlurVisualEffect.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 05/02/2025.
//

import FirebaseAnalytics
import Foundation
import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

struct PremiumBlurEffectModifier: ViewModifier {
    
    @Binding var showingSubscription: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(PremiumLockedView(showingSubscription: $showingSubscription))
    }
}

struct PremiumLockedView: View {
    
    @Binding var showingSubscription: Bool
    
    var body: some View {
        VisualEffectView(effect: UIBlurEffect(style: .light))
            .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radius))
            .overlay {
                VStack(spacing: CharterConstants.marginLarge) {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow.gradient)
                        .font(Font.system(size: 80))
                    
                    Text("Débloquer cette fonctionnalité")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Button {
                        Analytics.logEvent(LogEvent.unlockPremiumFeature, parameters: nil)
                        showingSubscription = true
                    } label: {
                        RoundedRectangle(cornerRadius: CharterConstants.radius)
                            .fill(CharterConstants.mainBlue)
                            .overlay {
                                Text("Essayer gratuitement")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20, weight: .semibold))
                            }
                    }
                    .frame(height: 50)
                }
                .padding(.horizontal, CharterConstants.margin)
            }
    }
}

extension View {
    func addPremiumBlurEffect(showingSubscription: Binding<Bool>) -> some View {
        modifier(PremiumBlurEffectModifier(showingSubscription: showingSubscription))
    }
}
