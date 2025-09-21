import Foundation

// Enum for the different categories in the Explore tab
enum ExploreCategory: String, CaseIterable, Identifiable {
    case psc = "Categories"
    case recipient = "Recipients"
    case state = "States"
    case industry = "Industries"
    case federalAccount = "Fed Acc."
    
    var id: String { self.rawValue }
}

@MainActor
class ExploreViewModel: ObservableObject {
    // Published properties for the view to observe
    @Published var pscCategories: [PSCChartData] = []
    @Published var recipients: [RecipientSpendingResult] = []
    @Published var states: [StateSpendingResult] = []
    @Published var industries: [NAICSSpendingResult] = []
    @Published var federalAccounts: [FederalAccountResult] = [] // New property
    
    @Published var viewState: LoadingState = .loading
    
    // Main function to fetch data based on the selected category
    func fetchData(for category: ExploreCategory, year: Int, quarter: Int) async {
        self.viewState = .loading
        
        do {
            switch category {
            case .psc:
                let response = try await APIService.shared.fetchTopPSCCategories(year: year, quarter: quarter)
                self.pscCategories = processPSCData(from: response.results)
            case .recipient:
                let response = try await APIService.shared.fetchRecipients(filter: .psc(""), year: year, quarter: quarter)
                self.recipients = response.results.filter { $0.recipientId != nil }
            case .state:
                let response = try await APIService.shared.fetchStateSpending(year: year, quarter: quarter)
                self.states = response.results
            case .industry:
                let response = try await APIService.shared.fetchNAICSSpending(year: year, quarter: quarter)
                self.industries = response.results
            case .federalAccount: // Handle the new case
                let response = try await APIService.shared.fetchFederalAccounts(year: year, quarter: quarter)
                self.federalAccounts = response.results
            }
            self.viewState = .success
        } catch let error as APIError {
            handleAPIError(error)
        } catch {
            self.viewState = .error("An unexpected error occurred.")
        }
    }

    // PSC processing logic to group individual codes into top-level categories
    private func processPSCData(from results: [PSCSpendingResult]) -> [PSCChartData] {
        var pscTotals: [String: Double] = [:]

        for result in results {
            let code = result.code
            let key: String
            
            if code.first?.isLetter == true && code.dropFirst().first?.isLetter == true {
                key = String(code.prefix(2))
            } else if code.first?.isLetter == true {
                key = String(code.prefix(1))
            } else {
                key = String(code.prefix(2))
            }
            pscTotals[key, default: 0] += result.amount
        }
        
        let processedList = pscTotals.compactMap { (key, amount) -> PSCChartData? in
            guard let name = PSCData.categories[key] else { return nil }
            return PSCChartData(code: key, name: name, amount: amount, color: .gray) // Color is unused here but required by struct
        }
        
        return processedList.sorted { $0.amount > $1.amount }
    }
    
    private func handleAPIError(_ error: APIError) {
        switch error {
        case .invalidURL:
            self.viewState = .error("The API endpoint URL is invalid.")
        case .networkError:
            self.viewState = .error("Network Error: Please check your internet connection and try again.")
        case .decodingError:
            self.viewState = .error("Data Parsing Error: The server's response was in an unexpected format.")
        case .invalidServerResponse(let statusCode, _):
            self.viewState = .error("Server Error: Received status code \(statusCode). Please try again later.")
        }
    }
}
