//
//  SubawardResponse.swift
//  GovLedger
//


import Foundation

struct SubawardResponse: Decodable {
    let results: [SubawardResult]
}

struct SubawardResult: Decodable, Identifiable, Hashable {
    // The API response for subawards doesn't have a stable unique ID,
    // so we'll generate one for SwiftUI's list identification.
    var id: UUID { UUID() }
    
    let description: String?
    let amount: Double?
    let recipientName: String?
    let actionDate: String?
    let subawardNumber: String?

    enum CodingKeys: String, CodingKey {
        case description
        case amount
        case recipientName = "recipient_name"
        case actionDate = "action_date"
        case subawardNumber = "subaward_number"
    }
}
