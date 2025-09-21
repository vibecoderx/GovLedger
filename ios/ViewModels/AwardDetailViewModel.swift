import Foundation

@MainActor
class AwardDetailViewModel: ObservableObject {
    @Published var subawards: [SubawardResult] = []
    @Published var awardDetails: AwardDetailsResponse?
    @Published var obligatedAmountInPeriod: Double? // New property for the calculated amount
    @Published var viewState: LoadingState = .loading

    // Updated function signature to accept the fiscal period
    func fetchAllAwardData(for awardId: String, fiscalYear: Int, fiscalQuarter: Int) async {
        self.viewState = .loading
        self.obligatedAmountInPeriod = nil // Reset on new fetch
        
        do {
            // Use a TaskGroup to run both API calls concurrently
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    let response = try await APIService.shared.fetchSubawards(for: awardId)
                    await MainActor.run {
                        self.subawards = response.results
                    }
                }
                
                group.addTask {
                    let response = try await APIService.shared.fetchAwardDetails(for: awardId)
                    await MainActor.run {
                        self.awardDetails = response
                    }
                }
                
                // Wait for both tasks to complete
                try await group.waitForAll()
            }
            
            // After data is fetched, perform the calculation
            calculateSpendingInPeriod(year: fiscalYear, quarter: fiscalQuarter)
            
            self.viewState = .success
        } catch let error as APIError {
            handleAPIError(error)
        } catch {
            self.viewState = .error("An unexpected error occurred.")
        }
    }

    // MARK: - Private Calculation Logic
    
    private func calculateSpendingInPeriod(year: Int, quarter: Int) {
        // Get the date range for the selected fiscal period
        let (startDateString, endDateString) = calculateDateRange(for: year, quarter: quarter)
        
        // Setup a date formatter to parse the "yyyy-MM-dd" format from the API
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDate = dateFormatter.date(from: startDateString),
              let endDate = dateFormatter.date(from: endDateString) else {
            return // Exit if we can't parse the date range
        }

        var total: Double = 0
        // Iterate through the fetched subawards
        for subaward in subawards {
            // Safely unwrap the date string and amount
            guard let dateString = subaward.actionDate,
                  let actionDate = dateFormatter.date(from: dateString),
                  let amount = subaward.amount else {
                continue // Skip if a subaward is missing data
            }
            
            // Check if the transaction date falls within our fiscal period
            if actionDate >= startDate && actionDate <= endDate {
                total += amount
            }
        }
        
        // Only set the property if there was spending in the period
        self.obligatedAmountInPeriod = total > 0 ? total : nil
    }
    
    // This is a helper to determine the date range, mirroring the logic in APIService.
    // Keeping it here makes the ViewModel's calculation logic self-contained.
    private func calculateDateRange(for year: Int, quarter: Int) -> (String, String) {
        let calendar = Calendar.current
        var components = DateComponents()
        components.calendar = calendar
        
        let startDate: Date
        let endDate: Date
        
        switch quarter {
        case 1: // Q1: Oct 1 - Dec 31 of the previous calendar year
            components.year = year - 1; components.month = 10; components.day = 1
            startDate = components.date!
            components.year = year - 1; components.month = 12; components.day = 31
            endDate = components.date!
        case 2: // Q2: Jan 1 - Mar 31 of the fiscal year
            components.year = year; components.month = 1; components.day = 1
            startDate = components.date!
            components.year = year; components.month = 3; components.day = 31
            endDate = components.date!
        case 3: // Q3: Apr 1 - Jun 30 of the fiscal year
            components.year = year; components.month = 4; components.day = 1
            startDate = components.date!
            components.year = year; components.month = 6; components.day = 30
            endDate = components.date!
        case 4: // Q4: Jul 1 - Sep 30 of the fiscal year
            components.year = year; components.month = 7; components.day = 1
            startDate = components.date!
            components.year = year; components.month = 9; components.day = 30
            endDate = components.date!
        default: // Case 0: The entire fiscal year
            components.year = year - 1; components.month = 10; components.day = 1
            startDate = components.date!
            components.year = year; components.month = 9; components.day = 30
            endDate = components.date!
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return (formatter.string(from: startDate), formatter.string(from: endDate))
    }
    
    // MARK: - Error Handling
    
    private func handleAPIError(_ error: APIError) {
        switch error {
        case .invalidURL:
            self.viewState = .error("The API endpoint URL is invalid.")
        case .networkError:
            self.viewState = .error("Network Error: Please check your internet connection and try again.")
        case .decodingError(let decodingError, let responseBody):
            print("Decoding Error: \(decodingError)")
            print("Response Body: \(responseBody)")
            self.viewState = .error("Data Parsing Error: The server's response was in an unexpected format.")
        case .invalidServerResponse(let statusCode, _):
            self.viewState = .error("Server Error: Received status code \(statusCode). Please try again later.")
        }
    }
}

