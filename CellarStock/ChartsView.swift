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
                            .font(.footnote)
                            .foregroundColor(.white)
                    }
                }
                .foregroundStyle(.blue)
                .frame(height: CGFloat(data.count * 70))
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

struct StepCount: Identifiable {
    
    let id = UUID()
    let name: String
    let count: Int
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}
