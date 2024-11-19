//
//  EntitlementManager.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 06/10/2024.
//

import SwiftUI

final class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults.standard
    
    @AppStorage("isPremium", store: userDefaults)
    var isPremium = false
    
    @AppStorage("winesPlus", store: userDefaults)
    var winesPlus = 0
    
    @AppStorage("winesSubmitted", store: userDefaults)
    var winesSubmitted = 0
    
    @AppStorage("clearNeeded", store: userDefaults)
    var clearNeeded = true
    
    @AppStorage("userId", store: userDefaults)
    var userId: String?
    
    @AppStorage("appLaunched", store: userDefaults)
    var appLaunched = 0
}
