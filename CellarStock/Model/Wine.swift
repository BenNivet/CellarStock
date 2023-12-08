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
    var type: WineType = WineType.rouge
    var region: Region = Region.bourgogne
    var appelation: Appelation = Appelation.pauillac
    var name: String = ""
    var owner: String = ""
    var info: String = ""
    
    init(type: WineType = .rouge, region: Region = .bourgogne, appelation: Appelation = .pauillac, name: String = "", owner: String = "", info: String = "") {
        self.type = type
        self.region = region
        self.appelation = appelation
        self.name = name
        self.owner = owner
        self.info = info
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
    var year: Int = 0
    var quantity: Int = 0
    var price: Double = 0
    
    init(id: UUID, year: Int = 0, quantity: Int = 0, price: Double = 0) {
        self.id = id
        self.year = year
        self.quantity = quantity
        self.price = price
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
