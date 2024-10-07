//
//  SubscriptionView.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 04/10/2024.
//

import FirebaseAnalytics
import SwiftUI
import StoreKit

struct SubscriptionView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
    
    @State private var selectedProduct: Product? = nil
    @State private var showRedeemCode: Bool = false
    
    private let features: [String] = ["Ajouter des vins en illimité",
                                      "Partager ma cave",
                                      "Suggestions de vins",
                                      "Aucune publicité"]
    
    @State private var showConfetti = false
    
    // MARK: - Layout
    var body: some View {
        if entitlementManager.isPremium {
            hasSubscriptionView
                .padding(.horizontal, CharterConstants.margin)
                .addLinearGradientBackground()
                .analyticsScreen(name: ScreenName.subscriptionSuccess)
                .displayConfetti(isActive: $showConfetti)
                .onAppear {
                    showConfetti = true
                }
                .task {
                    do {
                        try await Task.sleep(for: .seconds(7))
                        dismiss()
                    } catch {}
                }
        } else {
            subscriptionOptionsView
                .padding(.horizontal, CharterConstants.margin)
                .onAppear {
                    Task {
                        await subscriptionsManager.loadProducts()
                        selectedProduct = subscriptionsManager.products.first { $0.id == Subscription.popularId }
                    }
                }
                .offerCodeRedemption(isPresented: $showRedeemCode)
                .addLinearGradientBackground()
                .analyticsScreen(name: ScreenName.subscription)
                .overlay {
                    if subscriptionsManager.products.isEmpty {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1.5)
                    }
                }
        }
    }
    
    // MARK: - Views
    private var hasSubscriptionView: some View {
        VStack(spacing: CharterConstants.marginBig) {
            navView
            
            Spacer()
            Image(systemName: "crown.fill")
                .foregroundStyle(.yellow.gradient)
                .font(Font.system(size: 100))
            
            VStack(spacing: CharterConstants.marginMedium) {
                Text("Félicitations")
                    .font(.system(size: 33, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("Vous êtes désormais un membre Premium")
                    .font(.system(size: 25, weight: .semibold))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    private var subscriptionOptionsView: some View {
        VStack(spacing: CharterConstants.margin) {
            navView
            proAccessView
            featuresView
            Spacer()
            productsListView
            purchaseSection
        }
    }
    
    private var navView: some View {
        HStack {
            Button {
                dismiss()
                Analytics.logEvent(LogEvent.closeSubscription, parameters: nil)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            if !entitlementManager.isPremium {
                Button("Restaurer") {
                    Task {
                        try await AppStore.sync()
                        await subscriptionsManager.restorePurchases()
                    }
                }
                .font(.system(size: 14, weight: .regular))
                .frame(height: 15, alignment: .center)
                .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
    
    private var proAccessView: some View {
        VStack(spacing: CharterConstants.marginMedium) {
            Image(systemName: "crown.fill")
                .foregroundStyle(.yellow.gradient)
                .font(Font.system(size: 80))
            
            VStack(spacing: CharterConstants.marginSmall) {
                Text("Devenir premium")
                    .font(.system(size: 33, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("Débloquer toutes les fonctionnalités")
                    .font(.system(size: 17, weight: .semibold))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var featuresView: some View {
        VStack(alignment: .center, spacing: CharterConstants.margin) {
            ForEach(features, id: \.self) { feature in
                VStack {
                    HStack(spacing: CharterConstants.marginSmall) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.yellow.gradient)
                        
                        Text(feature)
                            .font(.system(size: 17, weight: .semibold))
                            .multilineTextAlignment(.center)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.yellow.gradient)
                    }
                }
            }
        }
        .padding(.top, CharterConstants.margin)
        .padding(.bottom, CharterConstants.marginLarge)
    }
    
    private var productsListView: some View {
        HStack(spacing: CharterConstants.marginMedium) {
            ForEach(subscriptionsManager.products, id: \.self) { product in
                SubscriptionItemView(product: product, selectedProduct: $selectedProduct)
                    .scaleEffect(selectedProduct == product ? 1.15 : 1, anchor: .bottom)
            }
        }
    }
    
    private var purchaseSection: some View {
        VStack(spacing: CharterConstants.margin) {
            VStack(spacing: CharterConstants.marginSmall) {
                purchaseButtonView
                HStack(spacing: CharterConstants.marginSmall) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.green.gradient)
                    Text("Sécurisé et sans engagment")
                        .font(.system(size: 13, weight: .regular))
                        .multilineTextAlignment(.center)
                }
            }
            HStack(spacing: 0) {
                Link("Conditions",
                     destination: URL(string: "http://www.apple.com/legal/itunes/appstore/dev/stdeula")!)
                Spacer()
                redeemButtonView
                Spacer()
                Link("Confidentialité",
                     destination: URL(string: "https://www.facebook.com/people/Vino-Cave/61554797827994/")!)
            }
            .font(.system(size: 14, weight: .regular))
            .frame(height: 15, alignment: .center)
            .foregroundStyle(.white.opacity(0.5))
        }
    }
    
    private var purchaseButtonView: some View {
        Button {
            if let selectedProduct {
                Task {
                    await subscriptionsManager.buyProduct(selectedProduct)
                }
                Analytics.logEvent(LogEvent.validateSubscription, parameters: nil)
            }
        } label: {
            RoundedRectangle(cornerRadius: CharterConstants.radiusSmall)
                .overlay {
                    Text("Essayer gratuitement")
                        .foregroundStyle(.white)
                        .font(.system(size: 16.5, weight: .semibold))
                }
        }
        .frame(height: 50)
        .disabled(selectedProduct == nil)
    }
    
    private var redeemButtonView: some View {
        Button("Code Promo") {
            showRedeemCode = true
            Analytics.logEvent(LogEvent.redeemSubscription, parameters: nil)
        }
        .font(.system(size: 14, weight: .regular))
        .frame(height: 15, alignment: .center)
        .foregroundStyle(.white.opacity(0.5))
    }
}

// MARK: Subscription Item
struct SubscriptionItemView: View {
    var product: Product
    @Binding var selectedProduct: Product?
    
    var body: some View {
        VStack(spacing: CharterConstants.margin) {
            Spacer()
            VStack(spacing: CharterConstants.marginSmall) {
                ForEach(product.displayName.components(separatedBy: " "), id: \.self) { word in
                    Text(word)
                        .font(.system(size: word.isInt ? 24 : 16, weight: .semibold))
                }
            }
            HStack {
                Spacer()
                Text("\(product.displayPrice)")
                    .font(.system(size: 15, weight: .semibold))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            Spacer()
        }
        .overlay(alignment: .top) {
            popularView
        }
        .background(
            LinearGradient(colors: [.blue, .black],
                           startPoint: .top,
                           endPoint: .bottom)
            .opacity(selectedProduct == product ? 1: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radiusSmall)
        )
        .opacity(selectedProduct == product ? 1: 0.7)
        .onTapGesture {
            withAnimation {
                selectedProduct = product
            }
        }
    }
    
    @ViewBuilder
    var popularView: some View {
        if product.id == Subscription.popularId {
            HStack {
                Spacer()
                Text("Populaire")
                    .foregroundStyle(.black)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .padding(.vertical, CharterConstants.marginXSmall)
            .background(Color.yellow.gradient)
            .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radiusSmall))
        }
    }
}
