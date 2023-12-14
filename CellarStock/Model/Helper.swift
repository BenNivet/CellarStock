//
//  Helper.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 21/11/2023.
//

import SwiftUI

class Helper {
    private let currentYear = Calendar.current.component(.year, from: Date())
    
    static let shared = Helper()
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    var creationDate: String {
        dateFormatter.string(from: Date())
    }
    
    func availableYears(for wine: Wine, selectedYears: [Int]) -> [Int] {
        var result: [Int] = []
        var loopYear = currentYear
        let limitYear = currentYear - 80
        while loopYear >= limitYear {
            if !selectedYears.contains(loopYear) {
                result.append(loopYear)
            }
            loopYear -= 1
        }
        return result
    }
}
