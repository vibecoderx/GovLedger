//
//  NAICSSpendingResponse.swift
//  GovSpendr
//


import Foundation

struct NAICSSpendingResponse: Decodable {
    let results: [NAICSSpendingResult]
}

struct NAICSSpendingResult: Decodable, Identifiable, Hashable {
    // The API uses 'name', which is unique for NAICS, as the ID.
    var id: String { name }
    
    let name: String
    let code: String
    let amount: Double
}
