//
//  ActionClosure.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 01/11/2023.
//

import Foundation

class ActionClosure {
    var handler: () -> Void
    
    init(handler: @escaping () -> Void) {
        self.handler = handler
    }
}
