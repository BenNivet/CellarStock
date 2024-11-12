//
//  FirestoreManager.swift
//  CellarStock
//
//  Created by CANTE Benjamin on 08/12/2023.
//

import Foundation
import FirebaseFirestore

@MainActor
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
    
    init() {
        db = Firestore.firestore()
    }
    
    func findUser(id: String) async -> String? {
        guard !id.isEmpty else { return nil }
        do {
            return try await withCheckedThrowingContinuation { continuation in
                db?.collection(Table.users.rawValue).document(id)
                    .getDocument { documentSnapshot, error in
                        if let documentSnapshot,
                           documentSnapshot.exists {
                            continuation.resume(returning: documentSnapshot.documentID)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    }
            }
        } catch {
            return nil
        }
    }
    
    func createUser(name: String = "") async -> String? {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                var ref: DocumentReference? = nil
                ref = try? db?.collection(Table.users.rawValue)
                    .addDocument(from: UserServer(name: name)) { _ in
                        continuation.resume(returning: ref?.documentID)
                    }
            }
        } catch {
            return nil
        }
    }
    
//    func clean() {
//        db?.collection(Table.wines.rawValue)
//            .getDocuments { [weak self] querySnapshot, err in
//                guard let documents = querySnapshot?.documents
//                else { return }
//                let docs = documents
//                    .filter({ doc in
//                        if let toto = doc.data()["userId"] as? String, !toto.isEmpty { return false }
//                        return true
//                    })
//                for doc in docs {
//                    self?.db?.collection(Table.wines.rawValue)
//                        .document(doc.documentID)
//                        .delete()
//                }
//            }
//        
//        db?.collection(Table.quantities.rawValue)
//            .getDocuments { [weak self] querySnapshot, err in
//                guard let documents = querySnapshot?.documents
//                else { return }
//                let docs = documents
//                    .filter({ doc in
//                        if let toto = doc.data()["userId"] as? String, !toto.isEmpty { return false }
//                        return true
//                    })
//                for doc in docs {
//                    self?.db?.collection(Table.quantities.rawValue)
//                        .document(doc.documentID)
//                        .delete()
//                }
//            }
//    }
    
    func fetchWines(for userId: String) async -> [Wine] {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                db?.collection(Table.wines.rawValue)
                    .whereField(Column.userId.rawValue, isEqualTo: userId)
                    .getDocuments { querySnapshot, err in
                        guard let documents = querySnapshot?.documents
                        else {
                            continuation.resume(returning: [])
                            return
                        }
                        continuation.resume(returning: documents
                            .compactMap { wineData -> Wine? in
                                guard let wineServer = try? wineData.data(as: WineServer.self)
                                else { return nil }
                                return Wine(wineServer: wineServer,
                                            documentId: wineData.documentID)})
                    }
            }
        } catch {
            return []
        }
    }
    
    func fetchQuantities(for userId: String) async -> [Quantity] {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                db?.collection(Table.quantities.rawValue)
                    .whereField(Column.userId.rawValue, isEqualTo: userId)
                    .getDocuments { querySnapshot, err in
                        guard let documents = querySnapshot?.documents
                        else {
                            continuation.resume(returning: [])
                            return
                        }
                        continuation.resume(returning: documents
                            .compactMap { quantityData -> Quantity? in
                                guard let quantityServer = try? quantityData.data(as: QuantityServer.self)
                                else { return nil }
                                return Quantity(quantityServer: quantityServer,
                                                documentId: quantityData.documentID)})
                    }
            }
        } catch {
            return []
        }
    }
    
    func insertQuantity(_ quantity: Quantity) async -> String? {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                var ref: DocumentReference? = nil
                ref = try? db?.collection(Table.quantities.rawValue)
                    .addDocument(from: quantity.quantityServer) { _ in
                        continuation.resume(returning: ref?.documentID)
                    }
            }
        } catch {
            return nil
        }
    }
    
    func insertOrUpdateWine(_ wine: Wine) async -> String? {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                if wine.wineId.isEmpty {
                    var ref: DocumentReference? = nil
                    ref = try? db?.collection(Table.wines.rawValue)
                        .addDocument(from: wine.wineServer) { _ in
                            continuation.resume(returning: ref?.documentID)
                        }
                } else {
                    try? db?.collection(Table.wines.rawValue)
                        .document(wine.wineId)
                        .setData(from: wine.wineServer)
                    continuation.resume(returning: wine.wineId)
                }
            }
        } catch {
            return nil
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
