//
//  Award.swift
//  GovSpendr
//

import Foundation

struct Award: Identifiable, Hashable {
    let id = UUID()
    let recipient: String
    let amount: Double
    let description: String
    let agencyName: String
}
