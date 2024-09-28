//
//  Wheel.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 12/11/2023.
//

import SwiftUI

struct Wheel: View {
    
    @Binding var rotation: CGFloat
    
    let segments: [String] = [[String]](repeating: ["bottle", "grape"], count: 4).flatMap { $0 }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(segments.indices, id: \.self) { index in
                    ZStack {
                        Circle()
                            .inset(by: proxy.size.width / 4)
                            .trim(from: CGFloat(index) * segmentSize, to: CGFloat(index + 1) * segmentSize)
                            .stroke(Color.wineColors[index % Color.wineColors.count].gradient,
                                    style: StrokeStyle(lineWidth: proxy.size.width / 2))
                            .rotationEffect(.radians(.pi * segmentSize))
                        image(name: segments[index], index: CGFloat(index), offset: proxy.size.width / 4)
                    }
                }
            }
            .background(Color.black)
            .clipShape(Circle())
        }
    }
    
    var segmentSize: CGFloat {
        1 / CGFloat(segments.count)
    }
    
    func rotation(index: CGFloat) -> CGFloat {
        (.pi * (2 * segmentSize * (CGFloat(index + 1))))
    }
    
    func image(name: String, index: CGFloat, offset: CGFloat) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .rotationEffect(.radians(rotation(index: CGFloat(index))) + .degrees(90))
            .offset(x: cos(rotation(index: index)) * offset, y: sin(rotation(index: index)) * offset)
    }
}

