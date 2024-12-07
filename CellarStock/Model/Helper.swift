//
//  Helper.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 21/11/2023.
//

import SwiftUI

final class Helper {
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let wineKeywords = ["CHATEAU", "DOMAINE", "CLOS"]
    private let escapeKeywords = ["DU", "DE", "DES", "LE", "LA", "LES", "UN", "UNE", "ET", "&"]
    
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
        if !selectedYears.contains(CharterConstants.withoutYear) {
            result.append(CharterConstants.withoutYear)
        }
        while loopYear >= limitYear {
            if !selectedYears.contains(loopYear) {
                result.append(loopYear)
            }
            loopYear -= 1
        }
        return result
    }
    
    func formatArrayWineName(lines: [String]) -> String {
        var elements: [String] = []
        var isEscaped = false
        
        for line in lines {
            guard var lastElement = elements.last
            else {
                elements.append(line)
                continue
            }
            if isMatched(line, array: escapeKeywords) {
                lastElement.append(" " + line)
                elements = elements.dropLast()
                elements.append(lastElement)
                isEscaped = true
            } else if isMatched(lastElement, array: wineKeywords) {
                elements = elements.dropLast()
                elements.append(lastElement + " " + line)
                isEscaped = false
            } else {
                if isEscaped {
                    elements = elements.dropLast()
                    elements.append(lastElement + " " + line)
                    isEscaped = false
                } else {
                    elements.append(line)
                    isEscaped = false
                }
            }
        }
        return elements.joined(separator: "\n")
    }
    
    private func isMatched(_ word: String, array: [String]) -> Bool {
        array.contains { word.compare($0, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }
    }
}
