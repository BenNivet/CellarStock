//
//  FeaturesView.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 03/01/2025.
//

import FirebaseAnalytics
import SwiftUI

struct Feature: Hashable {
    let index: Int
    let name: String
}

struct FeaturesView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var entitlementManager: EntitlementManager
    
    @State private var selectedFeatures: [Feature] = []
    
    private let features: [Feature] = [Feature(index: 0, name: String(localized: "Gestion multi-cave")),
                                       Feature(index: 1, name: String(localized: "Phases de vieillissement (jeunesse, maturité, apogée, déclin)")),
                                       Feature(index: 2, name: String(localized: "Ajouter des avis, des notes et des commentaires")),
                                       Feature(index: 3, name: String(localized: "Mettre des vins en favoris")),
                                       Feature(index: 4, name: String(localized: "Export PDF")),
                                       Feature(index: 5, name: String(localized: "Historique de consommation")),
                                       Feature(index: 6, name: String(localized: "Amelioration du scan")),
                                       Feature(index: 7, name: String(localized: "Accord mets / vins"))].shuffled()
    
    var body: some View {
        mainView
            .padding(CharterConstants.margin)
            .addLinearGradientBackground()
            .ignoresSafeArea(edges: .bottom)
    }
    
    var mainView: some View {
        VStack(spacing: CharterConstants.margin) {
            navView
            Text("Fonctionnalités")
                .font(.system(size: 33, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Choisissez les fonctionnalités que vous attendez le plus !")
                .font(.system(size: 17, weight: .semibold))
                .multilineTextAlignment(.center)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: CharterConstants.margin) {
                    ForEach(selectedFeatures + features.filter { !selectedFeatures.contains($0) }, id: \.self) { feature in
                        TileView {
                            HStack {
                                Spacer()
                                Text(feature.name)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                        } action: {
                            withAnimation {
                                if let index = selectedFeatures.firstIndex(of: feature) {
                                    selectedFeatures.remove(at: index)
                                } else {
                                    selectedFeatures.append(feature)
                                }
                            }
                        }
                        .background(selectedFeatures.contains(feature) ? CharterConstants.mainBlue.opacity(0.8) : nil)
                        .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radius))
                    }
                }
            }
        }
    }
    
    private var navView: some View {
        HStack {
            Button {
                Analytics.logEvent(LogEvent.closeFeatures, parameters: nil)
                dismiss()
            } label: {
                closeButtonView
            }
            Spacer()
            Button {
                for feature in selectedFeatures {
                    Analytics.logEvent(LogEvent.newFeature + String(feature.index), parameters: nil)
                }
                if !selectedFeatures.isEmpty {
                    entitlementManager.newFeatures2Validated = true
                }
                Analytics.logEvent(LogEvent.validateFeatures, parameters: nil)
                dismiss()
            } label: {
                Text("Valider")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(height: 24, alignment: .center)
                    .foregroundStyle(.white)
            }
        }
    }
}
