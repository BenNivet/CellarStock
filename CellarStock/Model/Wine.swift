//
//  Wine.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import Foundation
import SwiftData

@Model
final class Wine {
    var id: UUID = UUID()
    var userId: String = ""
    var wineId: String = ""
    var type: WineType = WineType.rouge
    var region: Region = Region.bourgogne
    var appelation: Appelation = Appelation.pauillac
    var name: String = ""
    var owner: String = ""
    var info: String = ""
    
    init(userId: String = "",
         wineId: String = "",
         type: WineType = .rouge,
         region: Region = .bourgogne,
         appelation: Appelation = .pauillac,
         name: String = "",
         owner: String = "",
         info: String = "") {
        self.wineId = wineId
        self.type = type
        self.region = region
        self.appelation = appelation
        self.name = name
        self.owner = owner
        self.info = info
    }
    
    init?(wineServer: WineServer, documentId: String) {
        guard let type = WineType(rawValue: wineServer.type),
              let region = Region(rawValue: wineServer.region),
              let appelation = Appelation(rawValue: wineServer.appelation)
        else { return nil }
        self.userId = wineServer.userId
        self.wineId = documentId
        self.type = type
        self.region = region
        self.appelation = appelation
        self.name = wineServer.name
        self.owner = wineServer.owner
        self.info = wineServer.info
    }
    
    var wineServer: WineServer {
        WineServer(userId: userId,
                   type: type.rawValue,
                   region: region.rawValue,
                   appelation: appelation.rawValue,
                   name: name,
                   owner: owner,
                   info: info)
    }
    
    func isMatch(for query: String) -> Bool {
        let queryFormatted = query.queryFormatted
        return type.description.queryFormatted.contains(queryFormatted)
        || region.description.queryFormatted.contains(queryFormatted)
        || (region == .bordeaux && appelation.description.queryFormatted.contains(queryFormatted))
        || name.queryFormatted.contains(queryFormatted)
        || owner.queryFormatted.contains(queryFormatted)
        || info.queryFormatted.contains(queryFormatted)
    }
}

@Model
final class Quantity {
    var id: UUID = UUID()
    var documentId: String = ""
    var wineId: String = ""
    var year: Int = 0
    var quantity: Int = 0
    var price: Double = 0
    
    init(documentId: String = "", 
         wineId: String = "",
         year: Int = 0,
         quantity: Int = 0,
         price: Double = 0) {
        self.wineId = wineId
        self.year = year
        self.quantity = quantity
        self.price = price
    }
    
    init(quantityServer: QuantityServer, documentId: String) {
        self.documentId = documentId
        self.wineId = quantityServer.wineId
        self.year = quantityServer.year
        self.quantity = quantityServer.quantity
        self.price = quantityServer.price
    }
    
    var quantityServer: QuantityServer {
        QuantityServer(wineId: wineId,
                       year: year,
                       quantity: quantity,
                       price: price)
    }
}

@Model
final class User {
    var id: UUID = UUID()
    var documentId: String = ""
    var name: String = ""
    
    init(documentId: String = "", name: String = "") {
        self.documentId = documentId
        self.name = name
    }
    
    init(userServer: UserServer) {
        name = userServer.name
    }
}

enum WineType: Int, CaseIterable, Identifiable, CustomStringConvertible, Codable {
    var id: Self { self }
    
    case rouge = 0
    case blanc
    case rose
    case petillant
    case other
    
    var description: String {
        switch self {
        case .rouge:
            "Rouge"
        case .blanc:
            "Blanc"
        case .rose:
            "Rosé"
        case .petillant:
            "Pétillant"
        case .other:
            "Autre"
        }
    }
}


enum Region: Int, CaseIterable, Identifiable, CustomStringConvertible, Codable {
    var id: Self { self }
    
    case bourgogne = 0
    case bordeaux
    case alsace
    case loire
    case rhone
    case champagne
    case beaujolais
    case juraSavoie
    case provence
    case languedocRoussillon
    case sudOuest
    case other
    
    var description: String {
        switch self {
        case .bourgogne:
            "Bourgogne"
        case .bordeaux:
             "Bordeaux"
        case .alsace:
            "Alsace"
        case .loire:
            "Pays de la loire"
        case .rhone:
            "Vallée du Rhone"
        case .champagne:
            "Champagne"
        case .beaujolais:
            "Beaujolais"
        case .juraSavoie:
            "Jura / Savoie"
        case .provence:
            "Provence"
        case .languedocRoussillon:
            "Languedoc / Roussillon"
        case .sudOuest:
            "Sud Ouest"
        case .other:
            "Autre"
        }
    }
}

enum Appelation: Int, CaseIterable, Identifiable, CustomStringConvertible, Codable {
    var id: Self { self }
    
    case pauillac = 0
    case saintEstephe
    case saintJulien
    case margaux
    case medoc
    case hautMedoc
    case listracMedoc
    case moulis
    case pessacleognan
    case cotesDeBordeaux
    case cotesDeBourg
    case sainteFoyBordeaux
    case bordeauxCotesDeFrancs
    case cotesDeCastillon
    case saintEmilion
    case lussacSaintEmilion
    case puisseguinSaintEmilion
    case montagneSaintEmilion
    case saintGeorgesSaintEmilion
    case pomerol
    case lalandeDePomerol
    case fronsac
    case canonFronsac
    case blaye
    case cotesDeBlaye
    case premieresCotesDeBlaye
    case graves
    case gravesDeVayres
    case gravesSuperieures
    case cremantDeBordeaux
    case barsac
    case bordeauxSuperieur
    case cerons
    case cotesDeBordeauxSaintMacaire
    case loupiac
    case sainteCroixduMont
    case sauternes
    case other
    
    var description: String {
        switch self {
        case .pauillac:
            "Pauillac"
        case .saintEstephe:
            "Saint Estèphe"
        case .saintJulien:
            "Saint Julien"
        case .margaux:
            "Margaux"
        case .medoc:
            "Médoc"
        case .hautMedoc:
            "Haut-Médoc"
        case .listracMedoc:
            "Listrac Médoc"
        case .moulis:
            "Moulis"
        case .pessacleognan:
            "Pessac-Léognan"
        case .cotesDeBordeaux:
            "Côtes de Bordeaux"
        case .cotesDeBourg:
            "Côtes de Bourg"
        case .sainteFoyBordeaux:
            "Sainte-Foy-Bordeaux"
        case .bordeauxCotesDeFrancs:
            "Bordeaux Côtes de Francs"
        case .cotesDeCastillon:
            "Côtes de Castillon"
        case .saintEmilion:
            "Saint-Emilion"
        case .lussacSaintEmilion:
            "Lussac Saint-Emilion"
        case .puisseguinSaintEmilion:
            "Puisseguin Saint-Emilion"
        case .montagneSaintEmilion:
            "Montagne Saint-Emilion"
        case .saintGeorgesSaintEmilion:
            "Saint Georges Saint-Emilion"
        case .pomerol:
            "Pomerol"
        case .lalandeDePomerol:
            "Lalande de Pomerol"
        case .fronsac:
            "Fronsac"
        case .canonFronsac:
            "Canon Fronsac"
        case .blaye:
            "Blaye"
        case .cotesDeBlaye:
            "Côtes de Blaye"
        case .premieresCotesDeBlaye:
            "Premières Côtes de Blaye"
        case .graves:
            "Graves"
        case .gravesDeVayres:
            "Graves de Vayres"
        case .gravesSuperieures:
            "Graves Supérieures"
        case .cremantDeBordeaux:
            "Crémant de Bordeaux"
        case .barsac:
            "Barsac"
        case .bordeauxSuperieur:
            "Bordeaux Supérieur"
        case .cerons:
            "Cérons"
        case .cotesDeBordeauxSaintMacaire:
            "Côtes de Bordeaux-Saint-Macaire"
        case .loupiac:
            "Loupiac"
        case .sainteCroixduMont:
            "Sainte-Croix-du-Mont"
        case .sauternes:
            "Sauternes"
        case .other:
            "Autre"
        }
    }
}

struct WineServer: Codable {
    var userId: String
    var type: Int
    var region: Int
    var appelation: Int
    var name: String
    var owner: String
    var info: String
}

struct QuantityServer: Codable {
    var wineId: String
    var year: Int
    var quantity: Int
    var price: Double
}

struct UserServer: Codable {
    var name: String
}
