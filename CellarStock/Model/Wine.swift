//
//  Wine.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            WineV2.self,
            QuantityV2.self,
            User.self
        ]
    }
    
    @Model
    final class WineV2 {
        var id: UUID = UUID()
        var userId: String = ""
        var wineId: String = ""
        var type: WineType = WineType.rouge
        var region: Region = Region.bourgogne
        var appelation: Appelation = Appelation.other
        var name: String = ""
        var owner: String = ""
        var info: String = ""
        var country: Country? = Country.france
        var size: Size? = Size.bouteille
        
        init(userId: String = "",
             wineId: String = "",
             type: WineType = .rouge,
             region: Region = .bourgogne,
             appelation: Appelation = .other,
             name: String = "",
             owner: String = "",
             info: String = "") {
            self.userId = userId
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
            self.wineId = documentId
            self.userId = wineServer.userId
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
    final class QuantityV2 {
        var id: UUID = UUID()
        var userId: String = ""
        var documentId: String = ""
        var wineId: String = ""
        var year: Int = 0
        var quantity: Int = 0
        var price: Double = 0
        
        init(userId: String = "",
             documentId: String = "",
             wineId: String = "",
             year: Int = 0,
             quantity: Int = 0,
             price: Double = 0) {
            self.userId = userId
            self.documentId = documentId
            self.wineId = wineId
            self.year = year
            self.quantity = quantity
            self.price = price
        }
        
        init(quantityServer: QuantityServer, documentId: String) {
            self.documentId = documentId
            self.userId = quantityServer.userId
            self.wineId = quantityServer.wineId
            self.year = quantityServer.year
            self.quantity = quantityServer.quantity
            self.price = quantityServer.price
        }
        
        var quantityServer: QuantityServer {
            QuantityServer(userId: userId,
                           wineId: wineId,
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
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            WineV2.self,
            QuantityV2.self,
            User.self
        ]
    }
    
    @Model
    final class WineV2 {
        var id: UUID = UUID()
        var userId: String = ""
        var wineId: String = ""
        var type: WineType = WineType.rouge
        var region: Region = Region.bourgogne
        var appelation: Appelation = Appelation.other
        var name: String = ""
        var owner: String = ""
        var info: String = ""
        var country: Country = Country.france
        var size: Size = Size.bouteille
        
        init(userId: String = "",
             wineId: String = "",
             type: WineType = .rouge,
             region: Region = .bourgogne,
             appelation: Appelation = .other,
             name: String = "",
             owner: String = "",
             info: String = "",
             country: Country = .france,
             size: Size = .bouteille) {
            self.userId = userId
            self.wineId = wineId
            self.type = type
            self.region = region
            self.appelation = appelation
            self.name = name
            self.owner = owner
            self.info = info
            self.country = country
            self.size = size
        }
        
        init?(wineServer: WineServer, documentId: String) {
            guard let type = WineType(rawValue: wineServer.type),
                  let region = Region(rawValue: wineServer.region),
                  let appelation = Appelation(rawValue: wineServer.appelation),
                  let country = Country(rawValue: wineServer.country ?? Country.france.rawValue),
                  let size = Size(rawValue: wineServer.size ?? Size.bouteille.rawValue)
            else { return nil }
            self.wineId = documentId
            self.userId = wineServer.userId
            self.type = type
            self.region = region
            self.appelation = appelation
            self.name = wineServer.name
            self.owner = wineServer.owner
            self.info = wineServer.info
            self.country = country
            self.size = size
        }
        
        var wineServer: WineServer {
            WineServer(userId: userId,
                       type: type.rawValue,
                       region: region.rawValue,
                       appelation: appelation.rawValue,
                       name: name,
                       owner: owner,
                       info: info,
                       country: country.rawValue,
                       size: size.rawValue)
        }
        
        func isMatch(for query: String) -> Bool {
            let queryFormatted = query.queryFormatted
            return type.description.queryFormatted.contains(queryFormatted)
            || region.description.queryFormatted.contains(queryFormatted)
            || (region == .bordeaux && appelation.description.queryFormatted.contains(queryFormatted))
            || name.queryFormatted.contains(queryFormatted)
            || owner.queryFormatted.contains(queryFormatted)
            || info.queryFormatted.contains(queryFormatted)
            || (size != .bouteille && size.description.queryFormatted.contains(queryFormatted))
        }
    }
    
    @Model
    final class QuantityV2 {
        var id: UUID = UUID()
        var userId: String = ""
        var documentId: String = ""
        var wineId: String = ""
        var year: Int = 0
        var quantity: Int = 0
        var price: Double = 0
        var date: String = Helper.shared.creationDate
        
        init(userId: String = "",
             documentId: String = "",
             wineId: String = "",
             year: Int = 0,
             quantity: Int = 0,
             price: Double = 0,
             date: String = Helper.shared.creationDate) {
            self.userId = userId
            self.documentId = documentId
            self.wineId = wineId
            self.year = year
            self.quantity = quantity
            self.price = price
            self.date = date
        }
        
        init(quantityServer: QuantityServer, documentId: String) {
            self.documentId = documentId
            self.userId = quantityServer.userId
            self.wineId = quantityServer.wineId
            self.year = quantityServer.year
            self.quantity = quantityServer.quantity
            self.price = quantityServer.price
            self.date = Helper.shared.creationDate
        }
        
        var quantityServer: QuantityServer {
            QuantityServer(userId: userId,
                           wineId: wineId,
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
    case moulisEnMedoc
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
        case .moulisEnMedoc:
            "Moulis-en-Médoc"
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

enum Country: Int, CaseIterable, Identifiable, CustomStringConvertible, Codable {
    var id: Self { self }
    
    case france = 0
    case italie
    case espagne
    case usa
    case argentine
    case australie
    case chili
    case afriqueDuSud
    case chine
    case allemagne
    case portugal
    case russie
    case roumanie
    case hongrie
    case autriche
    case grece
    case suisse
    case other
    
    var description: String {
        switch self {
        case .france:
            "France"
        case .italie:
            "Italie"
        case .espagne:
            "Espagne"
        case .usa:
            "États-Unis"
        case .argentine:
            "Argentine"
        case .australie:
            "Australie"
        case .chili:
            "Chili"
        case .afriqueDuSud:
            "Afrique du Sud"
        case .chine:
            "Chine"
        case .allemagne:
            "Allemagne"
        case .portugal:
            "Portugal"
        case .russie:
            "Russie"
        case .roumanie:
            "Roumanie"
        case .hongrie:
            "Hongrie"
        case .autriche:
            "Autriche"
        case .grece:
            "Grèce"
        case .suisse:
            "Suisse"
        case .other:
            "Autre"
        }
    }
}

enum Size: Int, CaseIterable, Identifiable, CustomStringConvertible, Codable {
    var id: Self { self }
    
    case bouteille = 1
    case magnum = 2
    case jeroboam = 4
    case mathusalem = 8
    case salmanazar = 12
    case balthazar = 16
    case nabuchodonosor = 20
    case salomon = 24
    
    var description: String {
        switch self {
        case .bouteille:
            "75 cl"
        case .magnum:
            "Magnum (1,5L)"
        case .jeroboam:
            "Jéroboam (3L)"
        case .mathusalem:
            "Mathusalem (6L)"
        case .salmanazar:
            "Salmanazar (9L)"
        case .balthazar:
            "Balthazar (12L)"
        case .nabuchodonosor:
            "Nabuchodonosor (15L)"
        case .salomon:
            "Salomon (18L)"
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
    var country: Int?
    var size: Int?
}

struct QuantityServer: Codable {
    var userId: String
    var wineId: String
    var year: Int
    var quantity: Int
    var price: Double
}

struct UserServer: Codable {
    var name: String
    var date: String = Helper.shared.creationDate
}
