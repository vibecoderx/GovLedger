import Foundation
import SwiftUI

// An enum to represent the different states our view can be in.
enum LoadingState: Equatable {
    case loading
    case success
    case error(String)
}

@MainActor // Ensures all UI updates happen on the main thread.
class DashboardViewModel: ObservableObject {
    // Published properties will automatically trigger UI updates when they change.
    @Published var topAgencies: [AgencySpendingResult] = []
    @Published var topPSCCategories: [PSCChartData] = []
    @Published var topRecipients: [RecipientSpendingResult] = []
    @Published var topCovidRecipients: [RecipientSpendingResult] = [] // New property for COVID recipients
    @Published var amountForMultipleRecipients: Double = 0
    @Published var totalSpending: Double = 0
    @Published var viewState: LoadingState = .loading
    
    // Color palettes for the charts
    private let agencyColors: [Color] = [.blue, .red, .orange, .green, .purple, .cyan, .indigo, .mint]
    private let pscColors: [Color] = [.cyan, .indigo, .purple, .teal, .pink, .orange, .green, .red]
    private let recipientColors: [Color] = [.green, .mint, .yellow, .pink, .blue, .red, .orange, .purple]
    private let covidRecipientColors: [Color] = [.pink, .red, .orange, .yellow, .mint, .teal, .blue, .indigo, .purple, .cyan]


    func fetchDashboardData(for fiscalYear: Int, quarter: Int) async {
        self.viewState = .loading
        
        // Reset data for new fetch
        self.topAgencies = []
        self.topPSCCategories = []
        self.topRecipients = []
        self.topCovidRecipients = []
        self.totalSpending = 0
        self.amountForMultipleRecipients = 0
        
        do {
            // Use a TaskGroup to run all API calls concurrently for better performance
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    let response = try await APIService.shared.fetchTopAgencySpending(year: fiscalYear, quarter: quarter, limit: 8)
                    await self.processAgencyData(from: response)
                }
                
                group.addTask {
                    let response = try await APIService.shared.fetchTopPSCCategories(year: fiscalYear, quarter: quarter)
                    await self.processPSCData(from: response)
                }

                group.addTask {
                    let response = try await APIService.shared.fetchRecipients(filter: .psc(""), year: fiscalYear, quarter: quarter)
                    await self.processRecipientData(from: response)
                }
                
                // New task to fetch COVID-19 recipients
                group.addTask {
                    let response = try await APIService.shared.fetchCovidRecipients(pscCodes: [], year: fiscalYear, quarter: quarter, limit: 10)
                    await self.processCovidRecipientData(from: response)
                }
                
                try await group.waitForAll()
            }
            
            self.viewState = .success
            
        } catch let error as APIError {
            handleAPIError(error)
        } catch {
            self.viewState = .error("An unexpected error occurred: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Processing Functions
    
    private func processAgencyData(from response: AgencySpendingResponse) {
        var processedAgencies = response.results.filter { $0.amount > 0 }
        self.totalSpending = processedAgencies.reduce(0) { $0 + $1.amount }

        for i in 0..<min(processedAgencies.count, agencyColors.count) {
            processedAgencies[i].color = agencyColors[i]
        }
        self.topAgencies = Array(processedAgencies.prefix(8))
    }

    private func processPSCData(from response: PSCSpendingResponse) {
        var pscTotals: [String: Double] = [:]

        for result in response.results {
            let code = result.code
            let key: String
            
            // --- FIX IS HERE ---
            // Convert to an array of characters to safely check character properties
            // without running into issues with the Substring type.
            let characters = Array(code)
            guard !characters.isEmpty else { continue }
            
            if characters.count > 1 {
                if characters[0].isLetter && characters[1].isLetter {
                    key = String(code.prefix(2))
                } else if characters[0].isLetter {
                    key = String(code.prefix(1))
                } else {
                    key = String(code.prefix(2))
                }
            } else {
                if characters[0].isLetter {
                    key = String(code.prefix(1))
                } else {
                    key = String(code.prefix(2)) // Handles single-digit codes
                }
            }
            // --- END OF FIX ---

            pscTotals[key, default: 0] += result.amount
        }
        
        var processedList = pscTotals.compactMap { (key, amount) -> PSCChartData? in
            guard let name = PSCData.categories[key] else { return nil }
            return PSCChartData(code: key, name: name, amount: amount, color: .gray)
        }.sorted { $0.amount > $1.amount }
        
        for i in 0..<min(processedList.count, pscColors.count) {
            processedList[i].color = pscColors[i]
        }
        
        self.topPSCCategories = Array(processedList.prefix(8))
    }
    
    private func processRecipientData(from response: RecipientSpendingResponse) {
        if let multipleRecipientsEntry = response.results.first(where: { $0.recipientId == nil }) {
            self.amountForMultipleRecipients = multipleRecipientsEntry.amount
        }
        var processedRecipients = response.results.filter { $0.recipientId != nil && $0.amount > 0 }
        
        for i in 0..<min(processedRecipients.count, recipientColors.count) {
            processedRecipients[i].color = recipientColors[i]
        }
        
        self.topRecipients = Array(processedRecipients.prefix(8))
    }
    
    private func processCovidRecipientData(from response: RecipientSpendingResponse) {
        var processedRecipients = response.results.filter { $0.recipientId != nil && $0.amount > 0 }
        
        for i in 0..<min(processedRecipients.count, covidRecipientColors.count) {
            processedRecipients[i].color = covidRecipientColors[i]
        }
        
        self.topCovidRecipients = Array(processedRecipients.prefix(10))
    }
    
    // MARK: - Error Handling
    
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

