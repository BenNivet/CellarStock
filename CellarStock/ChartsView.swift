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
    @State private var displayData: [StepCount] = []
    
    init(data: [StepCount]) {
        self.data = data
        _displayData = State(initialValue: data.map { step in
            var newStep = step
            newStep.count = 0
            return newStep
        })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                Chart(displayData) {
                    let count = $0.count
                    BarMark(
                        x: .value("Bottles", $0.count),
                        y: .value("Name", $0.name)
                    )
                    .cornerRadius(CharterConstants.radius)
                    .annotation(position: .overlay, alignment: .trailing) {
                        Text("\(count)")
                            .font(.callout)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                .foregroundStyle(LinearGradient(colors: [CharterConstants.mainBlue.opacity(0.25),
                                                         CharterConstants.mainBlue.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing))
                .frame(height: CGFloat(displayData.count * 80))
                .chartXAxis(.hidden)
                .chartXScale(type: .symmetricLog)
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.footnote)
                            .foregroundStyle(.white)
                    }
                }
                .padding(CharterConstants.margin)
            }
        }
        .task {
            withAnimation {
                displayData = data
            }
        }
    }
}

struct StepCount: Identifiable, Equatable {
    
    let id = UUID()
    let name: String
    var count: Int
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}
