//
//  SettingsViewModel.swift
//  GovLedger
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    // We use UserDefaults to persist the user's input across app launches
    @Published var taxContribution: Double = UserDefaults.standard.double(forKey: "taxContribution") {
        didSet {
            UserDefaults.standard.set(taxContribution, forKey: "taxContribution")
        }
    }
    
    // An estimated total federal tax revenue for calculation purposes
    let totalFederalTaxRevenue: Double = 4_900_000_000_000 // $4.9 Trillion (for 2024)
    
    func calculateContribution(for awardAmount: Double) -> Double {
        guard totalFederalTaxRevenue > 0, taxContribution > 0 else {
            return 0.0
        }
        let proportion = taxContribution / totalFederalTaxRevenue
        return proportion * awardAmount
    }
}
