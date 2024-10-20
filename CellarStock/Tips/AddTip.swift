//
//  AddTip.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 12/10/2024.
//

import Foundation
import TipKit

struct AddTip: Tip {
    var title: Text {
        Text("Ajouter un vin")
    }
    var message: Text? {
        Text("Ajouter un vin en cliquant sur le bouton \(Image(systemName: "plus"))")
    }
}
