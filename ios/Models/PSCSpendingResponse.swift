//
//  PSCSpendingResponse.swift
//  GovSpendr
//

import Foundation

// This struct is used to decode the response from the
// /v2/search/spending_by_category/psc/ endpoint.
struct PSCSpendingResponse: Decodable {
    let results: [PSCSpendingResult]
}

struct PSCSpendingResult: Decodable, Hashable {
    let code: String
    let amount: Double
    let name: String
}


