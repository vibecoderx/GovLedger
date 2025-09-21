import Foundation
import SwiftUI

// This struct is used to decode the response from the
// /v2/search/spending_by_category/funding_agency/ endpoint.
struct AgencySpendingResponse: Decodable {
    let results: [AgencySpendingResult]
}

struct AgencySpendingResult: Identifiable, Decodable, Hashable {
    var id: String { name }
    
    let name: String
    let code: String
    let amount: Double
    var color: Color = .gray
    
    // This computed property handles the display logic for agency names.
    var shortName: String {
        if name.starts(with: "Department of ") {
            return String(name.dropFirst("Department of ".count))
        }
        return name
    }
    
    // The CodingKeys enum correctly maps the JSON key "amount"
    // to our Swift property "amount".
    enum CodingKeys: String, CodingKey {
        case name
        case code
        case amount
    }
}
