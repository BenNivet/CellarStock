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
    
    @AppStorage("userId", store: userDefaults)
    var userId: String?
    
    @AppStorage("appLaunched", store: userDefaults)
    var appLaunched = 0
    
    @AppStorage("newFeatures2Validated", store: userDefaults)
    var newFeatures2Validated = false
    
    @AppStorage("newFeatures2DisplayedCount", store: userDefaults)
    var newFeatures2DisplayedCount = 0
    
    @AppStorage("minumumNewFeatures2DisplayDate", store: userDefaults)
    var minumumNewFeatures2DisplayDate = "2025/02/15"
}
