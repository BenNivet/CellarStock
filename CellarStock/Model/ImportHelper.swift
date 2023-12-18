//
//  ImportHelper.swift
//  CellarStock
//
//  Created by CANTE Benjamin (BPCE-SI) on 14/12/2023.
//

import Foundation

struct Import: Codable {
    var data: [WineImport]
}

struct WineImport: Codable {
    var region: String
    var type: String
    var appelation: String
    var name: String
    var year: Int
    var quantity: Int
    var price: Double
    
    func data(for userId: String) -> (Wine, Quantity)? {
        guard let wineRegion = Region.allCases.first(where: { $0.description == region }),
              let wineType = WineType.allCases.first(where: { $0.description == type }),
              let wineAppelation = Appelation.allCases.first(where: { $0.description == appelation })
        else { return nil }
        return (Wine(userId: userId, type: wineType, region: wineRegion, appelation: wineAppelation, name: name),
                Quantity(userId: userId, year: year, quantity: quantity, price: price))
    }
    
    enum CodingKeys: String, CodingKey {
        case region = "Region"
        case type = "Type"
        case appelation = "Appelation"
        case name = "Nom"
        case year = "Annee"
        case quantity = "Quantite"
        case price = "Prix"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.region = try container.decode(String.self, forKey: .region)
        self.type = try container.decode(String.self, forKey: .type)
        let appelation = try container.decode(String.self, forKey: .appelation)
        self.appelation = appelation.isEmpty ? Appelation.pauillac.description : appelation
        self.name = try container.decode(String.self, forKey: .name)
        self.year = try container.decode(Int.self, forKey: .year)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
        self.price = (try? container.decodeIfPresent(Double.self, forKey: .price)) ?? 0
    }
}
