//
//  AwardSpendingResponse.swift
//  GovSpendr
//


import Foundation

struct AwardSpendingResponse: Decodable {
    let results: [AwardResult]
}

struct AwardResult: Decodable, Identifiable, Hashable {
    // Using the "Award ID" as the unique identifier for list purposes.
    var id: String { awardId }
    
    let awardId: String
    let recipientName: String
    let awardAmount: Double
    let description: String?
    let state: String?
    let country: String?
    let generatedInternalId: String?

    // The API response uses keys with spaces, so explicit CodingKeys are required.
    enum CodingKeys: String, CodingKey {
        case awardId = "Award ID"
        case recipientName = "Recipient Name"
        case awardAmount = "Award Amount"
        case description = "Description"
        case state = "Place of Performance State Code"
        case country = "Place of Performance Country Code"
        case generatedInternalId = "generated_internal_id"
    }
}
