import Foundation

@MainActor
class AgencyDetailViewModel: ObservableObject {
    @Published var subAgencies: [SubAgencySpendingResult] = []
    @Published var viewState: LoadingState = .loading

    func fetchSubAgencies(for agency: AgencySpendingResult, year: Int, quarter: Int) async {
        self.viewState = .loading
        self.subAgencies = []

        do {
            let response = try await APIService.shared.fetchSubAgencies(for: agency, year: year, quarter: quarter)
            self.subAgencies = response.results.filter { $0.amount > 0 }
            self.viewState = .success
        } catch let error as APIError {
            handleAPIError(error)
        } catch {
            self.viewState = .error("An unexpected error occurred.")
        }
    }
    
    private func handleAPIError(_ error: APIError) {
        switch error {
        case .invalidURL:
            self.viewState = .error("The API endpoint URL is invalid.")
        case .networkError:
            self.viewState = .error("Network Error: Please check your internet connection.")
        case .decodingError(_, let responseBody):
            self.viewState = .error("Data Parsing Error. Response: \(responseBody)")
        case .invalidServerResponse(let statusCode, let responseBody):
            self.viewState = .error("Server Error: \(statusCode). Response: \(responseBody)")
        }
    }
}

