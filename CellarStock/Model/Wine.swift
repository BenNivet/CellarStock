//
//  Wine.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 30/09/2023.
//

import Foundation
import SwiftData

class Wine: Identifiable, Hashable {
    var id: String { wineId }
    var userId: String = ""
    var wineId: String = ""
    var type: WineType = WineType.rouge
    var region: Region = Region.bourgogne
    var appelation: Appelation = Appelation.other
    var usAppelation: USAppelation = USAppelation.other
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
         usAppelation: USAppelation = USAppelation.other,
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
        self.usAppelation = usAppelation
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
              let usAppelation = USAppelation(rawValue: wineServer.usAppelation ?? USAppelation.other.rawValue),
              let country = Country(rawValue: wineServer.country ?? Country.france.rawValue),
              let size = Size(rawValue: wineServer.size ?? Size.bouteille.rawValue)
        else { return nil }
        self.wineId = documentId
        self.userId = wineServer.userId
        self.type = type
        self.region = region
        self.appelation = appelation
        self.usAppelation = usAppelation
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
                   usAppelation: usAppelation.rawValue,
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
        || (country == .usa && usAppelation.description.queryFormatted.contains(queryFormatted))
        || (country != .france && country.description.queryFormatted.contains(queryFormatted))
        || name.queryFormatted.contains(queryFormatted)
        || owner.queryFormatted.contains(queryFormatted)
        || info.queryFormatted.contains(queryFormatted)
        || (size != .bouteille && size.description.queryFormatted.contains(queryFormatted))
    }
    
    static func == (lhs: Wine, rhs: Wine) -> Bool {
        lhs.wineId == rhs.wineId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

class Quantity: Identifiable, Hashable {
    var id: String { quantityId }
    var userId: String = ""
    var quantityId: String = ""
    var wineId: String = ""
    var year: Int = 0
    var quantity: Int = 0
    var price: Double = 0
    var date: String = Helper.shared.creationDate
    
    init(userId: String = "",
         quantityId: String = "",
         wineId: String = "",
         year: Int = 0,
         quantity: Int = 0,
         price: Double = 0,
         date: String = Helper.shared.creationDate) {
        self.userId = userId
        self.quantityId = quantityId
        self.wineId = wineId
        self.year = year
        self.quantity = quantity
        self.price = price
        self.date = date
    }
    
    init(quantityServer: QuantityServer, documentId: String) {
        self.quantityId = documentId
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
    
    static func == (lhs: Quantity, rhs: Quantity) -> Bool {
        lhs.quantityId == rhs.quantityId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

@Model
class User {
    var id: UUID = UUID()
    var documentId: String = ""
    var name: String = ""
    
    init(documentId: String = "", name: String = "") {
        self.documentId = documentId
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
            String(localized: "Rouge")
        case .blanc:
            String(localized: "Blanc")
        case .rose:
            String(localized: "Rosé")
        case .petillant:
            String(localized: "Pétillant")
        case .other:
            String(localized: "Autre")
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
            String(localized: "Autre")
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
            String(localized: "Autre")
        }
    }
}

enum USAppelation: Int, CaseIterable, Identifiable, CustomStringConvertible, Codable {
    var id: Self { self }
    
    case arizona = 0
    case californiaCentralCoast
    case californiaLivermoreValley
    case californiaPasoRobles
    case californiaYorkMountain
    case californiaCentralValley
    case californiaLodi
    case californiaNorthCoast
    case californiaMendocino
    case californiaNapaValley
    case californiaSonomaCounty
    case californiaSierraFoothills
    case californiaSouthCoast
    case colorado
    case idaho
    case michigan
    case missouri
    case newJersey
    case newMexico
    case newYorkFingerLakes
    case newYorkHudsonRiverRegion
    case newYorkLongIsland
    case oregonWillametteValley
    case pennsylvania
    case texasTexasHighPlains
    case texasTexasHillCountry
    case texasTransPecos
    case virginia
    case washingtonColumbiaValley
    case other
    
    var description: String {
        switch self {
        case .arizona:
            "Arizona"
        case .californiaCentralCoast:
            "California - Central Coast"
        case .californiaLivermoreValley:
            "California - Livermore Valley"
        case .californiaPasoRobles:
            "California - Paso Robles"
        case .californiaYorkMountain:
            "California - York Mountain"
        case .californiaCentralValley:
            "California - Central Valley"
        case .californiaLodi:
            "California - Lodi"
        case .californiaNorthCoast:
            "California - North Coast"
        case .californiaMendocino:
            "California - Mendocino"
        case .californiaNapaValley:
            "California - Napa Valley"
        case .californiaSonomaCounty:
            "California - Sonoma County"
        case .californiaSierraFoothills:
            "California - Sierra Foothills"
        case .californiaSouthCoast:
            "California - South Coast"
        case .colorado:
            "Colorado"
        case .idaho:
            "Idaho"
        case .michigan:
            "Michigan"
        case .missouri:
            "Missouri"
        case .newJersey:
            "New Jersey"
        case .newMexico:
            "New Mexico"
        case .newYorkFingerLakes:
            "New York - Finger Lakes"
        case .newYorkHudsonRiverRegion:
            "New York - Hudson River Region"
        case .newYorkLongIsland:
            "New York - Long Island"
        case .oregonWillametteValley:
            "Oregon - Willamette Valley"
        case .pennsylvania:
            "Pennsylvania"
        case .texasTexasHighPlains:
            "Texas - Texas High Plains"
        case .texasTexasHillCountry:
            "Texas - Texas Hill Country"
        case .texasTransPecos:
            "Texas - Trans-Pecos"
        case .virginia:
            "Virginia"
        case .washingtonColumbiaValley:
            "Washington - Columbia Valley"
        case .other:
            String(localized: "Autre")
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
    case newZealand
    case other
    
    var description: String {
        switch self {
        case .france:
            String(localized: "France")
        case .italie:
            String(localized: "Italie")
        case .espagne:
            String(localized: "Espagne")
        case .usa:
            String(localized: "États-Unis")
        case .argentine:
            String(localized: "Argentine")
        case .australie:
            String(localized: "Australie")
        case .chili:
            String(localized: "Chili")
        case .afriqueDuSud:
            String(localized: "Afrique du Sud")
        case .chine:
            String(localized: "Chine")
        case .allemagne:
            String(localized: "Allemagne")
        case .portugal:
            String(localized: "Portugal")
        case .russie:
            String(localized: "Russie")
        case .roumanie:
            String(localized: "Roumanie")
        case .hongrie:
            String(localized: "Hongrie")
        case .autriche:
            String(localized: "Autriche")
        case .grece:
            String(localized: "Grèce")
        case .suisse:
            String(localized: "Suisse")
        case .newZealand:
            String(localized: "Nouvelle-Zélande")
        case .other:
            String(localized: "Autre")
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
    var usAppelation: Int?
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
