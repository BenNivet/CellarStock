//
//  Constants.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 01/11/2023.
//

import Foundation
import SwiftUI

struct CharterConstants {
    // Margins
    static let margin: CGFloat = 16
    static let marginXXSmall: CGFloat = 2
    static let marginXSmall: CGFloat = 4
    static let marginSmall: CGFloat = 8
    static let marginMedium: CGFloat = 24
    static let marginLarge: CGFloat = 32
    static let marginBig: CGFloat = 40
    
    // Radius
    static let radiusXSmall: CGFloat = 4
    static let radiusSmall: CGFloat = 8
    static let radius: CGFloat = 16
    
    // Color
    static let redWine: Color = Color(UIColor(hexString: "#800020"))
    static let whiteWine: Color = Color(UIColor(hexString: "#FDE992"))
    static let roseWine: Color = Color(UIColor(hexString: "#EE7272"))
    static let sparklingWine: Color = Color(UIColor(hexString: "#FDEFB2"))
    
    // Alpha Transparency
    static let alphaFullyTransparent: CGFloat = 0
    static let alphaFive: CGFloat = 0.05
    static let alphaTen: CGFloat = 0.1
    static let alphaFifteen: CGFloat = 0.15
    static let alphaSixteen: CGFloat = 0.16
    static let alphaThirty: CGFloat = 0.3
    static let alphaFullyOpaque: CGFloat = 1
    
    // Opacity
    static let disabledOpacity: CGFloat = 0.6
}

struct ScreenName {
    static let wineList = "Wine_list"
    static let emptyWineList = "Wine_list_empty"
    static let addWine = "Add_wine"
    static let addWinePrice = "Add_wine_price"
    static let subscription = "Subscription"
    static let subscriptionSuccess = "Subscription_success"
    static let random = "Random"
    static let randomResult = "Random_result"
    static let stats = "Stats"
    static let scanWine = "Scan_wine"
}

struct LogEvent {
    static let addWine = "Add_wine"
    static let updateWine = "Update_wine"
    static let deleteWine = "Delete_wine"
    static let joinCellar = "Join_cellar"
    static let shareCellar = "Share_cellar"
    static let deleteCellar = "Delete_cellar"
    static let closeSubscription = "Close_subscription"
    static let validateSubscription = "Validate_subscription"
    static let redeemSubscription = "Reedem_subscription"
}

struct Subscription {
    static let popularId = "Yearly"
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32

        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension Color {
    static var wineColors: [Color] {
        [CharterConstants.redWine, CharterConstants.sparklingWine]
    }
}

extension String {
    var queryFormatted: String {
        folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
}

extension Double {
    var toRoundedString: String {
        if floor(self) == self {
            String(Int(self))
        } else {
            String(format: "%.2f", self)
        }
    }
}

extension Int {
    var bottlesString: String {
        if self > 1 {
            "\(self) bouteilles"
        } else {
            "\(self) bouteille"
        }
    }
}

extension String {
    var isInt: Bool {
        Int(self) != nil
    }
}
