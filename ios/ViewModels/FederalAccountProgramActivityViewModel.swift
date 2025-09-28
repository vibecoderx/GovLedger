//
//  FederalAccountProgramActivityViewModel.swift
//  GovLedger
//

import Foundation

@MainActor
class FederalAccountProgramActivityViewModel: ObservableObject {
    @Published var programActivities: [ProgramActivityResult] = []
    @Published var viewState: LoadingState = .loading

    func fetchProgramActivities(for accountCode: String, year: Int) async {
        self.viewState = .loading
        do {
            let response = try await APIService.shared.fetchProgramActivities(for: accountCode, fiscalYear: year)
            self.programActivities = response.results
            self.viewState = .success
        } catch let error as APIError {
            viewState = .error(error.localizedDescription)
        } catch {
            viewState = .error("An unexpected error occurred.")
        }
    }
}
