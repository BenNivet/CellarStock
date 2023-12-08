//
//  RandomView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 01/11/2023.
//

import SwiftUI
import SwiftData

struct RandomView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var wines: [Wine]
    @Query private var quantities: [Quantity]
    @State private var rotation: CGFloat = 0.0
    @State private var showingSheet: (Bool, Wine, Quantity) = (false, Wine(), Quantity(id: UUID()))
    @State private var filterRegions: [Int] = []
    @State private var filterTypes: [Int] = []
    @State private var filterYears: [Int] = []
    @State private var showingAlert = false
    
    private var animationDuration: TimeInterval = 2
    
    var body: some View {
        NavigationStack {
            VStack(spacing: CharterConstants.margin) {
                filterView
                ZStack {
                    Wheel(rotation: $rotation)
                        .rotationEffect(.radians(rotation))
                        .animation(.easeInOut(duration: animationDuration), value: rotation)
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .symbolRenderingMode(.multicolor)
                        .foregroundColor(.black)
                        .onTapGesture {
                            let randomAmount = Double(Int.random(in: 7..<15))
                            rotation += randomAmount
                            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                                if let (wine, quantity) = randomWine {
                                    showingSheet = (true, wine, quantity)
                                } else {
                                    showingAlert = true
                                }
                            }
                        }
                        .sheet(isPresented: $showingSheet.0) {
                            CongratsView(wine: $showingSheet.1, quantity: $showingSheet.2)
                                .presentationDetents([.large, .medium])
                        }
                        .alert("Aucun vin ne correspond à vos critères", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
                }
                .padding(CharterConstants.marginMedium)
            }
            .background {
                Image("wallpaper4")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            }
        }
    }
    
    private var filterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CharterConstants.margin) {
                FilterItem(type: .region, filteringElements: $filterRegions)
                FilterItem(type: .type, filteringElements: $filterTypes)
                FilterItem(type: .year, filteringElements: $filterYears)
            }
            .padding(CharterConstants.margin)
        }
    }
    
    private var randomWine: (Wine, Quantity)? {
        var selectableWines = wines
        if !filterRegions.isEmpty {
            selectableWines = selectableWines.filter { filterRegions.contains($0.region.rawValue) }
        }
        if !filterTypes.isEmpty {
            selectableWines = selectableWines.filter { filterTypes.contains($0.type.rawValue) }
        }
        if !filterYears.isEmpty {
            selectableWines = selectableWines.filter { wine in
                !quantities.filter({ quantity in
                    quantity.id == wine.id && filterYears.contains(quantity.year)
                }).isEmpty
            }
        }
        guard let wine = selectableWines.randomElement(),
              let quantity = quantities.filter({ quantity in
                  if !filterYears.isEmpty {
                      return quantity.id == wine.id && filterYears.contains(quantity.year)
                  } else {
                      return quantity.id == wine.id
                  }
              }).randomElement()
        else { return nil }
        
        return (wine, quantity)
    }
    
    func quantity(for wine: Wine) -> Int {
        var result = 0
        for quantity in quantities.filter({ $0.id == wine.id }) {
            result += quantity.quantity
        }
        return result
    }
}
