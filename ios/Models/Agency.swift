import Foundation
import SwiftUI

// This class is now simplified. It's only used as a temporary object
// for navigation purposes from the Dashboard. The live data is handled
// by the AgencySpendingResult struct.
class Agency: Identifiable, Decodable, Hashable {
    let id = UUID()
    var color: Color

    let agencyName: String
    let toptierCode: String
    let obligatedAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case agencyName
        case toptierCode
        case obligatedAmount
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.agencyName = try container.decode(String.self, forKey: .agencyName)
        self.toptierCode = try container.decode(String.self, forKey: .toptierCode)
        self.obligatedAmount = try container.decode(Double.self, forKey: .obligatedAmount)
        self.color = .gray
    }
    
    init(name: String, toptierCode: String = "000", totalSpending: Double, color: Color) {
        self.agencyName = name
        self.toptierCode = toptierCode
        self.obligatedAmount = totalSpending
        self.color = color
    }
    
    // MARK: - Hashable Conformance
    
    static func == (lhs: Agency, rhs: Agency) -> Bool {
        lhs.toptierCode == rhs.toptierCode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(toptierCode)
    }
}
