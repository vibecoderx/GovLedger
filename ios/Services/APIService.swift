import Foundation

// A custom error enum to provide specific details about network failures.
enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error, String)
    case invalidServerResponse(Int, String)
}

class APIService {
    static let shared = APIService()
    private init() {}
    
    private let baseURL = "https://api.usaspending.gov/api/v2"

    // MARK: - Agency Spending
    func fetchTopAgencySpending(year: Int, quarter: Int, limit: Int = 50) async throws -> AgencySpendingResponse {
        print("DEBUG: fetchTopAgencySpending")
        let endpoint = "/search/spending_by_category/funding_agency/"
        let (startDate, endDate) = calculateDateRange(for: year, quarter: quarter)
        let payload: [String: Any] = [
            "category": "funding_agency",
            "filters": [ "time_period": [["start_date": startDate, "end_date": endDate]] ],
            "limit": limit
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }

    // MARK: - Sub-Agency Spending
    func fetchSubAgencies(for agency: AgencySpendingResult, year: Int, quarter: Int) async throws -> SubAgencySpendingResponse {
        print("DEBUG: fetchSubAgencies: \(agency)")
        let endpoint = "/search/spending_by_category/funding_subagency/"
        let (startDate, endDate) = calculateDateRange(for: year, quarter: quarter)
        let payload: [String: Any] = [
            "category": "funding_subagency",
            "filters": [
                "agencies": [
                    ["type": "funding", "tier": "toptier", "name": agency.name]
                ],
                "time_period": [
                    ["start_date": startDate, "end_date": endDate]
                ]
            ],
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }

    // MARK: - PSC Spending
    func fetchTopPSCCategories(year: Int, quarter: Int) async throws -> PSCSpendingResponse {
        print("DEBUG: fetchTopPSCCategories")
        let endpoint = "/search/spending_by_category/psc/"
        let (startDate, endDate) = calculateDateRange(for: year, quarter: quarter)
        let payload: [String: Any] = [
            "category": "psc",
            "filters": [ "time_period": [["start_date": startDate, "end_date": endDate]] ],
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }

    // MARK: - Recipient Spending (Generic)
    func fetchRecipients(filter: RecipientFilter, year: Int, quarter: Int) async throws -> RecipientSpendingResponse {
        print("DEBUG: fetchRecipients: \(filter)")
        let endpoint = "/search/spending_by_category/recipient/"
        let (startDate, endDate) = calculateDateRange(for: year, quarter: quarter)
        
        var filters: [String: Any] = [
            "time_period": [["start_date": startDate, "end_date": endDate]]
        ]

        switch filter {
        case .psc(let code):
            if !code.isEmpty {
                filters["psc_codes"] = [code]
            }
        case .state(let code):
            if !code.isEmpty {
                filters["place_of_performance_locations"] = [["country": "USA", "state": code]]
            }
        case .industry(let code):
            if !code.isEmpty {
                filters["naics_codes"] = [code]
            }
        case .federalAccount:
             // This case is now invalid for recipients, as per API limitations.
             // We can throw an error or handle it gracefully. Here, we'll let it pass
             // and the UI will show an empty list, which is a reasonable fallback.
            break
        }
        
        let payload: [String: Any] = [
            "category": "recipient",
            "filters": filters,
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }
    
    // MARK: - State Spending
    func fetchStateSpending(year: Int, quarter: Int) async throws -> StateSpendingResponse {
        print("DEBUG: fetchStateSpending: ")
        let endpoint = "/search/spending_by_category/state_territory/"
        let (startDate, endDate) = calculateDateRange(for: year, quarter: quarter)
        let payload: [String: Any] = [
            "filters": [ "time_period": [["start_date": startDate, "end_date": endDate]] ],
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }

    // MARK: - NAICS Spending
    func fetchNAICSSpending(year: Int, quarter: Int) async throws -> NAICSSpendingResponse {
        print("DEBUG: fetchNAICSSpending:")
        let endpoint = "/search/spending_by_category/naics/"
        let (startDate, endDate) = calculateDateRange(for: year, quarter: quarter)
        let payload: [String: Any] = [
            "category": "naics",
            "filters": [ "time_period": [["start_date": startDate, "end_date": endDate]] ],
            "limit": 50
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }
    
    // MARK: - Federal Account Spending
    func fetchFederalAccounts(year: Int, quarter: Int) async throws -> FederalAccountResponse {
        print("DEBUG: fetchFederalAccounts")
        let endpoint = "/search/spending_by_category/federal_account/"
        let (startDate, endDate) = calculateDateRange(for: year, quarter: quarter)
        let payload: [String: Any] = [
            "category": "federal_account",
            "filters": [ "time_period": [["start_date": startDate, "end_date": endDate]] ],
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }
    
    // New function for Program Activities within a Federal Account
    func fetchProgramActivities(for federalAccountCode: String, fiscalYear: Int) async throws -> FederalAccountProgramActivityResponse {
        print("DEBUG: fetchProgramActivities for account: \(federalAccountCode)")
        let endpoint = "/federal_accounts/\(federalAccountCode)/program_activities"
        let urlString = baseURL + endpoint + "?fiscal_year=\(fiscalYear)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await executeRequest(for: request)
    }

    // MARK: - Award Spending
    func fetchAwards(for subAgency: SubAgencySpendingResult, fiscalYear: Int, fiscalQuarter: Int) async throws -> AwardSpendingResponse {
        print("DEBUG: fetchAwards: \(subAgency)")
        let endpoint = "/search/spending_by_award/"
        let (startDate, endDate) = calculateDateRange(for: fiscalYear, quarter: fiscalQuarter)
        let filters: [String: Any] = [
            "award_type_codes": ["A", "B", "C", "D"],
            "agencies": [
                [
                    "type": "funding",
                    "tier": "subtier",
                    "name": subAgency.name
                ]
            ],
            "time_period": [
                [
                    "start_date": startDate,
                    "end_date": endDate
                ]
            ]
        ]
        let payload: [String: Any] = [
            "filters": filters,
            "fields": ["Award ID", "Recipient Name", "Award Amount", "Description", "Place of Performance State Code", "Place of Performance Country Code", "generated_internal_id"],
            "sort": "Award Amount",
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }
    
    func fetchAwards(for recipientUei: String, fiscalYear: Int, fiscalQuarter: Int) async throws -> AwardSpendingResponse {
        print("DEBUG: fetchAwards: \(recipientUei)")
        let endpoint = "/search/spending_by_award/"
        let (startDate, endDate) = calculateDateRange(for: fiscalYear, quarter: fiscalQuarter)
        let filters: [String: Any] = [
            "award_type_codes": ["A", "B", "C", "D"],
            "recipient_search_text": [recipientUei],
            "time_period": [["start_date": startDate, "end_date": endDate]]
        ]
        let payload: [String: Any] = [
            "filters": filters,
            "fields": ["Award ID", "Recipient Name", "Award Amount", "Description", "Place of Performance State Code", "Place of Performance Country Code", "generated_internal_id"],
            "sort": "Award Amount",
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }
    
    func fetchAwards(for recipientUei: String, pscCode: String, fiscalYear: Int, fiscalQuarter: Int) async throws -> AwardSpendingResponse {
        print("DEBUG: fetchAwards for recipient UEI: \(recipientUei) and PSC Code: \(pscCode)")
        let endpoint = "/search/spending_by_award/"
        let (startDate, endDate) = calculateDateRange(for: fiscalYear, quarter: fiscalQuarter)
        let filters: [String: Any] = [
            "award_type_codes": ["A", "B", "C", "D"],
            "recipient_search_text": [recipientUei],
            "psc_codes": [pscCode],
            "time_period": [["start_date": startDate, "end_date": endDate]]
        ]
        let payload: [String: Any] = [
            "filters": filters,
            "fields": ["Award ID", "Recipient Name", "Award Amount", "Description", "Place of Performance State Code", "Place of Performance Country Code", "generated_internal_id"],
            "sort": "Award Amount",
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }
    
    func fetchAwards(for recipientUei: String, stateCode: String, fiscalYear: Int, fiscalQuarter: Int) async throws -> AwardSpendingResponse {
        print("DEBUG: fetchAwards for recipient UEI: \(recipientUei) and State Code: \(stateCode)")
        let endpoint = "/search/spending_by_award/"
        let (startDate, endDate) = calculateDateRange(for: fiscalYear, quarter: fiscalQuarter)
        let filters: [String: Any] = [
            "award_type_codes": ["A", "B", "C", "D"],
            "recipient_search_text": [recipientUei],
            "place_of_performance_locations": [
                ["country": "USA", "state": stateCode]
            ],
            "time_period": [["start_date": startDate, "end_date": endDate]]
        ]
        let payload: [String: Any] = [
            "filters": filters,
            "fields": ["Award ID", "Recipient Name", "Award Amount", "Description", "Place of Performance State Code", "Place of Performance Country Code", "generated_internal_id"],
            "sort": "Award Amount",
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }
    
    func fetchAwards(for recipientUei: String, naicsCode: String, fiscalYear: Int, fiscalQuarter: Int) async throws -> AwardSpendingResponse {
        print("DEBUG: fetchAwards for recipient UEI: \(recipientUei) and NAICS Code: \(naicsCode)")
        let endpoint = "/search/spending_by_award/"
        let (startDate, endDate) = calculateDateRange(for: fiscalYear, quarter: fiscalQuarter)
        let filters: [String: Any] = [
            "award_type_codes": ["A", "B", "C", "D"],
            "recipient_search_text": [recipientUei],
            "naics_codes": [naicsCode],
            "time_period": [["start_date": startDate, "end_date": endDate]]
        ]
        let payload: [String: Any] = [
            "filters": filters,
            "fields": ["Award ID", "Recipient Name", "Award Amount", "Description", "Place of Performance State Code", "Place of Performance Country Code", "generated_internal_id"],
            "sort": "Award Amount",
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }
    
    // MARK: - Keyword Search for Awards
    func fetchAwards(keyword: String, fiscalYear: Int, fiscalQuarter: Int) async throws -> AwardSpendingResponse {
        print("DEBUG: fetchAwards: \(keyword)")
        let endpoint = "/search/spending_by_award/"
        let (startDate, endDate) = calculateDateRange(for: fiscalYear, quarter: fiscalQuarter)
        
        let filters: [String: Any] = [
            "award_type_codes": ["A", "B", "C", "D"],
            "keywords": [keyword],
            "time_period": [["start_date": startDate, "end_date": endDate]]
        ]
        
        let payload: [String: Any] = [
            "filters": filters,
            "fields": ["Award ID", "Recipient Name", "Award Amount", "Description", "Place of Performance State Code", "Place of Performance Country Code", "generated_internal_id"],
            "sort": "Award Amount",
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }
    
    // MARK: - COVID-19 Spending
    func fetchCovidRecipients(pscCodes: [String], year: Int, quarter: Int, limit: Int) async throws -> RecipientSpendingResponse {
        print("DEBUG: fetchCovidRecipients")
        let endpoint = "/search/spending_by_category/recipient/"
        let (startDate, endDate) = calculateDateRange(for: year, quarter: quarter)
        
        var filters: [String: Any] = [
            "time_period": [["start_date": startDate, "end_date": endDate]],
            "def_codes": ["L", "M", "N", "O", "P", "U", "V"]
        ]

        if !pscCodes.isEmpty {
            filters["psc_codes"] = pscCodes
        }
        
        let payload: [String: Any] = [
            "category": "recipient",
            "filters": filters,
            "limit": limit
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }

    func fetchCovidAwards(for recipientUei: String, fiscalYear: Int, fiscalQuarter: Int) async throws -> AwardSpendingResponse {
        print("DEBUG: fetchCovidAwards for recipient UEI: \(recipientUei)")
        let endpoint = "/search/spending_by_award/"
        let (startDate, endDate) = calculateDateRange(for: fiscalYear, quarter: fiscalQuarter)
        
        let awardTypeCodes = ["A", "B", "C", "D"] //, "02", "03", "04", "05", "06", "07", "08", "09", "10", "11"]
        
        let filterFields = ["Award ID", "Recipient Name", "Award Amount", "Description", "Place of Performance State Code", "Place of Performance Country Code", "generated_internal_id"]
        
        var filters: [String: Any] = [:]
        filters["award_type_codes"] = awardTypeCodes
        filters["recipient_search_text"] = [recipientUei]
        filters["def_codes"] = ["L", "M", "N", "O", "P", "U", "V"]
        filters["time_period"] = [["start_date": startDate, "end_date": endDate]]
        
        let payload: [String: Any] = [
            "filters": filters,
            "fields": filterFields,
            "sort": "Award Amount",
            "limit": 100
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }
    
    // MARK: - Award Details
    func fetchAwardDetails(for awardId: String) async throws -> AwardDetailsResponse {
        print("DEBUG: fetchAwardDetails for awardId: \(awardId)")
        let endpoint = "/awards/\(awardId)/"
        return try await performGETRequest(endpoint: endpoint)
    }

    // MARK: - Subaward Spending
    func fetchSubawards(for awardId: String) async throws -> SubawardResponse {
        print("DEBUG: fetchSubAwards: \(awardId)")
        let endpoint = "/subawards/"
        let payload: [String: Any] = [
            "page": 1,
            "limit": 100,
            "sort": "amount",
            "order": "desc",
            "award_id": awardId
        ]
        return try await performPOSTRequest(endpoint: endpoint, payload: payload)
    }

    // MARK: - Generic Request Helpers
    private func performPOSTRequest<T: Decodable>(endpoint: String, payload: [String: Any]) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            throw APIError.networkError(error)
        }
        
        return try await executeRequest(for: request)
    }
    
    private func performGETRequest<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await executeRequest(for: request)
    }
    
    private func executeRequest<T: Decodable>(for request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                let responseBody = String(data: data, encoding: .utf8) ?? "No response body."
                throw APIError.invalidServerResponse(statusCode, responseBody)
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch let error as DecodingError {
                let responseBody = String(data: data, encoding: .utf8) ?? "Could not read response data."
                throw APIError.decodingError(error, responseBody)
            }
            
        } catch let error as APIError {
            throw error // Re-throw our specific API errors
        } catch {
            throw APIError.networkError(error) // Catch other network errors
        }
    }

    // MARK: - Date Calculation Helper
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
}

