//
//  StateSpendingResponse.swift
//  GovLedger
//


import Foundation

struct StateSpendingResponse: Decodable {
    let results: [StateSpendingResult]
}

struct StateSpendingResult: Decodable, Identifiable, Hashable {
    // The API response for state territories doesn't have a stable unique ID,
    // so we'll generate one for SwiftUI's list identification.
    var id: UUID { UUID() }
    
    let name: String?
    let code: String?
    let amount: Double
}
