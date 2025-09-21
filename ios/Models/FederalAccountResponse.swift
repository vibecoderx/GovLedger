//
//  FederalAccountResponse.swift
//  GovSpendr
//

import Foundation

// This struct is used to decode the response from the
// /v2/search/spending_by_category/federal_account/ endpoint.
struct FederalAccountResponse: Decodable {
    let results: [FederalAccountResult]
}

struct FederalAccountResult: Decodable, Identifiable, Hashable {
    // The account code is a reliable unique identifier.
    var id: String { code }
    
    let name: String
    let code: String
    let amount: Double
}

