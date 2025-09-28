//
//  CovidSpendingViewModel.swift
//  GovLedger
//

import Foundation

// Enum for the different categories in the COVID-19 tab
enum CovidCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case medical = "Medical"
    case business = "Business"
    case logistics = "Logistics"
    
    var id: String { self.rawValue }

    // This computed property returns the appropriate PSC codes for the API call
    var pscCodes: [String] {
        switch self {
        case .all:
            return [] // No PSC filter for the "All" category
        case .medical:
            return ["AN", "Q", "65", "66"]
        case .business:
            return ["R708", "V", "99"]
        case .logistics:
            return ["D", "V", "R4"]
        }
    }
}

@MainActor
class CovidSpendingViewModel: ObservableObject {
    @Published var recipients: [RecipientSpendingResult] = []
    @Published var amountForMultipleRecipients: Double = 0
    @Published var viewState: LoadingState = .loading
    
    func fetchRecipients(for category: CovidCategory, year: Int, quarter: Int) async {
        self.viewState = .loading
        
        do {
            let response = try await APIService.shared.fetchCovidRecipients(
                pscCodes: category.pscCodes,
                year: year,
                quarter: quarter,
                limit: 100
            )
            
            if let multipleRecipients = response.results.first(where: { $0.recipientId == nil }) {
                self.amountForMultipleRecipients = multipleRecipients.amount
            }
            self.recipients = response.results.filter { $0.recipientId != nil }
            
            self.viewState = .success
        } catch let error as APIError {
            self.viewState = .error(error.localizedDescription)
        } catch {
            self.viewState = .error("An unexpected error occurred.")
        }
    }
}


