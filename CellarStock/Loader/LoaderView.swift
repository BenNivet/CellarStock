//
//  LoaderView.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 14/10/2024.
//

import Combine
import SwiftUI

struct LoaderView: View {
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let timing: Double

    private let maxCounter = 3
    @State private var counter = 0

    let frame: CGSize
    let primaryColor: Color

    init(color: Color = .white, size: CGFloat = 50, speed: Double = 0.5) {
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
                        ForEach(0 ..< maxCounter, id: \.self) { index in
                            Circle()
                                .offset(y: counter == index ? -frame.height / 5 : frame.height / 5)
                                .fill(primaryColor)
                        }
                    }
                    .frame(width: frame.width, height: frame.height)
                    .onReceive(timer) { _ in
                        withAnimation(.easeInOut(duration: timing * 3)) {
                            counter = counter == (maxCounter - 1) ? 0 : counter + 1
                        }
                    }
                }
                .frame(width: 125, height: 125)
                .background(.black.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: CharterConstants.radius))
                Spacer()
            }
            Spacer()
        }
        .background(.white.opacity(CharterConstants.alphaFifteen))
        .ignoresSafeArea()
    }
}
