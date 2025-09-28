//
//  SubAgencySpendingResponse.swift
//  GovLedger
//

import Foundation

struct SubAgencySpendingResponse: Decodable {
    let results: [SubAgencySpendingResult]
}

// Added Hashable conformance for SwiftUI Navigation
struct SubAgencySpendingResult: Decodable, Identifiable, Hashable {
    // Use the name as the ID, as it's unique within the response
    var id: String { name }
    let name: String
    let amount: Double
    let parentAgency: String

    enum CodingKeys: String, CodingKey {
        case name
        case amount
        case parentAgency = "agency_name"
    }
}
