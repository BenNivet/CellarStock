//
//  ChartsView.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 07/12/2023.
//

import Charts
import SwiftUI
import SwiftData

struct ChartsView: View {
    
    let data: [StepCount]
    
    var body: some View {
        VStack {
            ScrollView {
                Chart(data) {
                    let count = $0.count
                    BarMark(
                        x: .value("Bottles", $0.count),
                        y: .value("Name", $0.name)
                    )
                    .cornerRadius(CharterConstants.radiusSmall)
                    .annotation(position: .trailing) {
                        Text("\(count)")
                            .font(.callout)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                .foregroundStyle(LinearGradient(colors: [.blue.opacity(0.25), .blue.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing))
                .frame(height: CGFloat(data.count * 80))
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.footnote)
                            .foregroundStyle(.white)
                    }
                }
                .padding(CharterConstants.margin)
            }
            Spacer()
        }
    }
}

struct StepCount: Identifiable, Equatable {
    
    let id = UUID()
    let name: String
    let count: Int
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}
