//
//  EntitlementManager.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 06/10/2024.
//

import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults.standard
    
    @AppStorage("isPremium", store: userDefaults)
    var isPremium = false
    
    @AppStorage("winesSubmitted", store: userDefaults)
    var winesSubmitted = 0
}
