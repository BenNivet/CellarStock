//
//  LoaderView.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 14/10/2024.
//

import SwiftUI
import Combine

struct LoaderView: View {
    
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let timing: Double
    
    private let maxCounter = 3
    @State private var counter = 0
    
    let frame: CGSize
    let primaryColor: Color

    init(color: Color = .white, size: CGFloat = 60, speed: Double = 0.5) {
        timing = speed / 2
        timer = Timer.publish(every: timing, on: .main, in: .common).autoconnect()
        frame = CGSize(width: size, height: size)
        primaryColor = color
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    HStack(spacing: CharterConstants.marginSmall) {
                        ForEach(0..<maxCounter, id: \.self) { index in
                            Circle()
                                .offset(y: counter == index ? -frame.height / 10 : frame.height / 10)
                                .fill(primaryColor)
                        }
                    }
                    .frame(width: frame.width, height: frame.height)
                    .onReceive(timer) { _ in
                        withAnimation(.easeInOut(duration: timing * 2)) {
                            counter = counter == (maxCounter - 1) ? 0 : counter + 1
                        }
                    }
                }
                .frame(width: 150, height: 150)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radiusSmall))
                Spacer()
            }
            Spacer()
        }
        .background(.gray.opacity(CharterConstants.alphaFifteen))
        .ignoresSafeArea()
    }
}
