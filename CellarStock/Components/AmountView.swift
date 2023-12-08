//
//  AmountView.swift
//  CellarStock
//
//  Created by CANTE Benjamin (BPCE-SI) on 04/12/2023.
//

import SwiftUI

struct AmountView: View {
    @Environment(\.dismiss) var dismiss
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
        VStack {
            HStack {
                Text("Prix")
                Spacer()
                TextField("Prix", text: $amount)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .focused($isAmountFocus)
                Text("€")
            }
            .padding(CharterConstants.margin)
            .background(.gray.opacity(CharterConstants.alphaFifteen))
            .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radiusSmall))
            Spacer()
            HStack {
                Spacer()
                Text("Valider")
                    .font(.body.bold())
                    .foregroundStyle(.black)
                Spacer()
            }
            .frame(height: 40)
            .contentShape(Rectangle())
            .onTapGesture {
                if let amountDouble = Double(amount) {
                    pricesByYear[year] = amountDouble
                }
                year = 0
                dismiss()
            }
            .onLongPressGesture(minimumDuration: .infinity,
                                maximumDistance: .infinity) {
                isPressed = true
            } onPressingChanged: { state in
                isPressed = state
            }
            .padding(CharterConstants.margin)
            .background(backgroundColor)
            .frame(height: 40)
            .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radiusSmall))
        }
        .onAppear {
            isAmountFocus = true
        }
        .padding(CharterConstants.margin)
    }
    
    private var backgroundColor: Color {
        if isPressed {
            .white.opacity(0.8)
        } else {
            .white
        }
    }
}
