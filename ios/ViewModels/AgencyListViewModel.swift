//
//  AgencyListViewModel.swift
//  GovSpendr
//


import Foundation
import SwiftUI

@MainActor
class AgencyListViewModel: ObservableObject {
    @Published var agencies: [AgencySpendingResult] = []
    @Published var viewState: LoadingState = .loading
    
    /// Fetches the list of top-tier agencies for a given fiscal period.
    func fetchAgencies(year: Int, quarter: Int) async {
        self.viewState = .loading
        
        do {
            let response = try await APIService.shared.fetchTopAgencySpending(year: year, quarter: quarter)
            self.agencies = response.results
            self.viewState = .success
        } catch let error as APIError {
            self.viewState = .error(error.localizedDescription)
        } catch {
            self.viewState = .error("An unexpected error occurred.")
        }
    }
}
