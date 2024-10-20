//
//  Confetti.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 06/10/2024.
//

import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    @State private var xSpeed = Double.random(in: 0.7...2)
    @State private var zSpeed = Double.random(in: 1...2)
    @State private var anchor = CGFloat.random(in: 0...1).rounded()
    
    var body: some View {
        Rectangle()
            .fill([Color.orange, Color.green, Color.blue, Color.red, Color.yellow].randomElement() ?? Color.green)
            .frame(width: 20, height: 20)
            .onAppear(perform: { animate = true })
            .rotation3DEffect(.degrees(animate ? 360 : 0), axis: (x: 1, y: 0, z: 0))
            .animation(Animation.linear(duration: xSpeed).repeatForever(autoreverses: false), value: animate)
            .rotation3DEffect(.degrees(animate ? 360 : 0), axis: (x: 0, y: 0, z: 1), anchor: UnitPoint(x: anchor, y: anchor))
            .animation(Animation.linear(duration: zSpeed).repeatForever(autoreverses: false), value: animate)
    }
}

struct ConfettiContainerView: View {
    var count = 75
    @State private var yPosition: CGFloat = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { _ in
                ConfettiView()
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: yPosition != 0 ? CGFloat.random(in: 0...UIScreen.main.bounds.height) : yPosition
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            yPosition = CGFloat.random(in: 0...UIScreen.main.bounds.height)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

struct DisplayConfettiModifier: ViewModifier {
    @Binding var isActive: Bool {
        didSet {
            if !isActive {
                opacity = 1
            }
        }
    }
    @State private var opacity = 1.0 {
        didSet {
            if opacity == 0 {
                isActive = false
            }
        }
    }
    
    @State private var sensorFeedback = false
    
    private let animationTime = 5
    private let fadeTime = 2.0
    
    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(ConfettiContainerView().opacity(opacity))
                .sensoryFeedback(.success, trigger: sensorFeedback)
                .task {
                    sensorFeedback = true
                    await handleAnimationSequence()
                }
        } else {
            content
        }
    }
    
    private func handleAnimationSequence() async {
        try? await Task.sleep(for: .seconds(animationTime))
        withAnimation(.easeOut(duration: fadeTime)) {
            opacity = 0
        }
    }
}

extension View {
    func displayConfetti(isActive: Binding<Bool>) -> some View {
        modifier(DisplayConfettiModifier(isActive: isActive))
    }
}
