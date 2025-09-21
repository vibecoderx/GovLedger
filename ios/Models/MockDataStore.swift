import Foundation
import SwiftUI

// This is where all our mock data lives.
struct MockDataStore {

    // MARK: - App-wide Data
    static let totalSpending: Double = 6_270_000_000_000 // $6.27 Trillion

    // MARK: - Agencies (Updated)
    // This mock data is now only used for previews. The initializers have been
    // updated to match the simplified Agency model without sub-agencies.
    static let agencies: [Agency] = [
        Agency(name: "Department of Health", totalSpending: 1_200_000_000_000, color: .blue),
        Agency(name: "Department of Defense", totalSpending: 750_000_000_000, color: .red),
        Agency(name: "Department of Transportation", totalSpending: 90_000_000_000, color: .orange)
    ]
    
    // MARK: - Explore Categories
    static let topPSCs: [PSC] = [
        PSC(id: "H115", name: "Medical Services", totalSpending: 85_000_000_000, color: .cyan),
        PSC(id: "D302", name: "IT Systems Development", totalSpending: 60_000_000_000, color: .indigo),
        PSC(id: "R425", name: "Engineering Services", totalSpending: 55_000_000_000, color: .purple),
        PSC(id: "AJ11", name: "Aeronautics Research", totalSpending: 40_000_000_000, color: .teal)
    ]
    
    static let topRecipients: [Recipient] = [
        Recipient(id: "12345", name: "Lockheed Martin", totalSpending: 45_000_000_000, color: .green),
        Recipient(id: "67890", name: "Pfizer Inc.", totalSpending: 32_000_000_000, color: .mint),
        Recipient(id: "13579", name: "Raytheon Technologies", totalSpending: 28_000_000_000, color: .yellow),
        Recipient(id: "24680", name: "General Dynamics", totalSpending: 25_000_000_000, color: .pink)
    ]
}

