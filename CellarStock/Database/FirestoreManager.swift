//
//  FirestoreManager.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 08/12/2023.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    enum Table: String {
        case users = "Users"
        case wines = "Wines"
        case quantities = "Quantities"
    }
    
    enum Column: String {
        case userId
    }
    
    static let shared = FirestoreManager()
    var db: Firestore?
    
    func initDb() {
        db = Firestore.firestore()
    }
    
    func findUser(id: String, completion: @escaping (String?) -> Void) {
        guard !id.isEmpty
        else {
            completion(nil)
            return
        }
        db?.collection(Table.users.rawValue).document(id)
            .getDocument { documentSnapshot, error in
                if let documentSnapshot,
                   documentSnapshot.exists {
                    completion(documentSnapshot.documentID)
                } else {
                    completion(nil)
                }
            }
    }
    
    func createUser(name: String = "", completion: @escaping (String?) -> Void) {
        var ref: DocumentReference? = nil
        ref = try? db?.collection(Table.users.rawValue)
            .addDocument(from: UserServer(name: name)) { _ in
                completion(ref?.documentID)
            }
    }
    
    func clean() {
        db?.collection(Table.wines.rawValue)
            .getDocuments { [weak self] querySnapshot, err in
                guard let documents = querySnapshot?.documents
                else { return }
                let docs = documents
                    .filter({ doc in
                        if let toto = doc.data()["userId"] as? String, !toto.isEmpty { return false }
                        return true
                    })
                for doc in docs {
                    self?.db?.collection(Table.wines.rawValue)
                        .document(doc.documentID)
                        .delete()
                }
            }
        
        db?.collection(Table.quantities.rawValue)
            .getDocuments { [weak self] querySnapshot, err in
                guard let documents = querySnapshot?.documents
                else { return }
                let docs = documents
                    .filter({ doc in
                        if let toto = doc.data()["userId"] as? String, !toto.isEmpty { return false }
                        return true
                    })
                for doc in docs {
                    self?.db?.collection(Table.quantities.rawValue)
                        .document(doc.documentID)
                        .delete()
                }
            }
    }
    
    func fetchWines(for userId: String, completion: @escaping ([Wine]) -> Void) {
        db?.collection(Table.wines.rawValue)
            .whereField(Column.userId.rawValue, isEqualTo: userId)
            .getDocuments { querySnapshot, err in
                guard let documents = querySnapshot?.documents
                else {
                    completion([])
                    return
                }
                completion(documents
                    .compactMap { wineData -> Wine? in
                        guard let wineServer = try? wineData.data(as: WineServer.self)
                        else { return nil }
                        return Wine(wineServer: wineServer,
                                    documentId: wineData.documentID)})
            }
    }
    
    func fetchQuantities(for userId: String, completion: @escaping ([Quantity]) -> Void) {
        db?.collection(Table.quantities.rawValue)
            .whereField(Column.userId.rawValue, isEqualTo: userId)
            .getDocuments { querySnapshot, err in
                guard let documents = querySnapshot?.documents
                else {
                    completion([])
                    return
                }
                completion(documents
                    .compactMap { quantityData -> Quantity? in
                        guard let quantityServer = try? quantityData.data(as: QuantityServer.self)
                        else { return nil }
                        return Quantity(quantityServer: quantityServer,
                                        documentId: quantityData.documentID)})
            }
    }
    
    func insertQuantity(_ quantity: Quantity, completion: @escaping (String?) -> Void) {
        var ref: DocumentReference? = nil
        ref = try? db?.collection(Table.quantities.rawValue)
            .addDocument(from: quantity.quantityServer) { _ in
                completion(ref?.documentID)
            }
    }
    
    func insertOrUpdateWine(_ wine: Wine, completion: @escaping (String?) -> Void) {
        if wine.wineId.isEmpty {
            var ref: DocumentReference? = nil
            ref = try? db?.collection(Table.wines.rawValue)
                .addDocument(from: wine.wineServer) { _ in
                    completion(ref?.documentID)
                }
        } else {
            try? db?.collection(Table.wines.rawValue)
                .document(wine.wineId)
                .setData(from: wine.wineServer)
            completion(wine.wineId)
        }
    }
    
    func updateQuantity(_ quantity: Quantity) {
        try? db?.collection(Table.quantities.rawValue)
            .document(quantity.documentId)
            .setData(from: quantity.quantityServer)
    }
    
    func deleteQuantity(_ quantity: Quantity) {
        db?.collection(Table.quantities.rawValue)
            .document(quantity.documentId)
            .delete()
    }
    
    func deleteWine(_ wine: Wine) {
        db?.collection(Table.wines.rawValue)
            .document(wine.wineId)
            .delete()
    }
}
