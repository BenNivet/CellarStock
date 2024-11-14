//
//  AmountView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 04/12/2023.
//

import SwiftUI

struct AmountView: View {
    
    @Binding var year: Int
    @Binding var pricesByYear: [Int: Double]
    
    @State private var isPressed = false
    @State private var amount: String
    
    @FocusState private var isAmountFocus: Bool
    
    init(year: Binding<Int>, pricesByYear: Binding<[Int: Double]>) {
        _year = year
        _pricesByYear = pricesByYear
        let amountInt = Int(pricesByYear[year.wrappedValue].wrappedValue ?? 0)
        if amountInt == 0 {
            _amount = State(wrappedValue: "")
        } else {
            _amount = State(wrappedValue: String(amountInt))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                FloatingTextField(placeHolder: String(localized: "Prix"), text: $amount, rightIconString: String(describing: Locale.current.currencySymbol ?? "€"))
                    .keyboardType(.numberPad)
                    .focused($isAmountFocus)
                
                Spacer()
                
                Button("Valider") {
                    if let amountDouble = Double(amount) {
                        pricesByYear[year] = amountDouble
                    }
                    year = 0
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .onAppear {
                isAmountFocus = true
            }
            .padding(CharterConstants.margin)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        year = 0
                    } label: {
                        closeButtonView
                    }
                }
            }
        }
    }
}
