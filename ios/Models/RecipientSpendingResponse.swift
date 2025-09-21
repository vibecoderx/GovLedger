import Foundation
import SwiftUI

struct RecipientSpendingResponse: Decodable {
    let results: [RecipientSpendingResult]
}

struct RecipientSpendingResult: Decodable, Identifiable, Hashable {
    // Use the recipientId for the Identifiable conformance, falling back to name.
    var id: String { recipientUei ?? recipientId ?? name }

    let name: String
    let amount: Double
    let code: String?
    let recipientId: String?
    let recipientUei: String?
    var color: Color = .gray // Added color property for chart consistency

    enum CodingKeys: String, CodingKey {
        case name, amount, code
        case recipientId = "recipient_id"
        case recipientUei = "uei"
    }
}
