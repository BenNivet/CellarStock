//
//  Item.swift
//  CellarStock
//
//  Created by CANTE Benjamin (BPCE-SI) on 30/09/2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
