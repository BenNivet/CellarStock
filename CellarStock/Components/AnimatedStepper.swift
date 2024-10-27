//
//  AnimatedStepper.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 22/10/2024.
//

import SwiftUI

struct AnimatedStepper: View {
    
    @State private var currentNumber: Int
    @State private var dragWidth: CGFloat = 0
    
    var onIncrement: (() -> Void)?
    var onDecrement: (() -> Void)?
    
    init(currentNumber: Int, onIncrement: (() -> Void)?, onDecrement: (() -> Void)?) {
        _currentNumber = State(initialValue: currentNumber)
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }
    
    var minNumber = 0
    var size: CGFloat = 40
    
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
            currentNumber -= 1
            onDecrement?()
        }
    }
    
    private func increment() {
        currentNumber += 1
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
            icon(systemName: "minus")
                .opacity(isMin() ? 0.4 : 1)
                .onTapGesture {
                    withAnimation(.linear) {
                        decrement()
                    }
                }
                .padding(.horizontal, CharterConstants.marginSmall)
            
            Color.clear
                .frame(width: size, height: size)
            
            icon(systemName: "plus")
                .onTapGesture {
                    withAnimation(.linear) {
                        increment()
                    }
                }
                .padding(.horizontal, CharterConstants.marginSmall)
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
