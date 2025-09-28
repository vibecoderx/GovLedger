//
//  FilterViewModel.swift
//  GovLedger
//


import Foundation
import Combine

class FilterViewModel: ObservableObject {
    // MARK: - Published Properties
    // These will automatically update any view using this ViewModel
    @Published var selectedYear: Int
    @Published var selectedQuarter: Int = 0 // 0 means "All Quarters"

    // MARK: - Public Properties
    let availableYears: [Int]
    let quarters = [0, 1, 2, 3, 4]

    // MARK: - Initialization
    init() {
        let currentFiscalYear = FilterViewModel.calculateCurrentFiscalYear()
        self.selectedYear = currentFiscalYear
        
        // Populate the list of available years from 2015 to the current fiscal year
        self.availableYears = Array(2015...currentFiscalYear).reversed()
    }

    // MARK: - Computed Properties
    var quarterDisplayString: String {
        if selectedQuarter == 0 {
            return "All Quarters"
        } else {
            return "Q\(selectedQuarter)"
        }
    }
    
    // MARK: - Static Helper
    /// Calculates the current US federal fiscal year.
    /// The fiscal year starts on October 1st of the previous calendar year.
    static func calculateCurrentFiscalYear() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        
        // If the month is October, November, or December, the fiscal year is the next calendar year.
        return month >= 10 ? year + 1 : year
    }
}
