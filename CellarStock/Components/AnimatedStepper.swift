//
//  AnimatedStepper.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 22/10/2024.
//

import SwiftUI

struct AnimatedStepper: View {
    
    @Binding var currentNumber: Int
    @State private var dragWidth: CGFloat = 0
    
    var onIncrement: (() -> Void)?
    var onDecrement: (() -> Void)?
    
    init(currentNumber: Binding<Int>, onIncrement: (() -> Void)?, onDecrement: (() -> Void)?) {
        _currentNumber = currentNumber
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }
    
    var minNumber = 0
    var size: CGFloat = CharterConstants.quantitySize
    
    private func isMin() -> Bool {
        currentNumber == minNumber
    }
    
    private func shouldDecrease() -> Bool {
        dragWidth < -size / 2.4
    }
    
    private func shouldIncrease() -> Bool {
        dragWidth > size / 2.4
    }
    
    private func decrement() {
        if !isMin() {
            onDecrement?()
        }
    }
    
    private func increment() {
        onIncrement?()
    }
    
    private func icon(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 16))
            .foregroundColor(.white)
            .contentShape(Rectangle())
    }
    
    private let spring = Animation.spring(response: 0.4, dampingFraction: 0.6)
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.linear) {
                    decrement()
                }
            } label: {
                icon(systemName: "minus")
                    .padding(.horizontal, CharterConstants.marginSmall)
            }
            
            Color.clear
                .frame(width: size, height: size)
            
            Button {
                withAnimation(.linear) {
                    increment()
                }
            } label: {
                icon(systemName: "plus")
                    .padding(.horizontal, CharterConstants.marginSmall)
            }
        }
        .frame(height: size)
        .background(
            Capsule()
                .fill(CharterConstants.halfGray)
        )
        .overlay {
            Text("\(currentNumber)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: CharterConstants.radius, x: 0, y: 0)
                )
                .offset(x: dragWidth)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let absoluteWidth = abs(dragWidth)
                            let threshold = size / 2 * 2
                            
                            if absoluteWidth < threshold {
                                withAnimation(spring) {
                                    if (isMin() && value.translation.width < 0) {
                                        dragWidth = value.translation.width * 0.1
                                    } else {
                                        dragWidth = value.translation.width * max((threshold + size / 2 - absoluteWidth) / 100, 0.1) * 1.2
                                    }
                                }
                            }
                        }
                        .onEnded { _ in
                            if shouldIncrease() {
                                increment()
                            } else if shouldDecrease() {
                                decrement()
                            }
                            
                            withAnimation(spring) {
                                dragWidth = .zero
                            }
                        }
                )
        }
        .clipShape(Capsule())
    }
}
