import Foundation

/// An enum to define the different ways we can filter for awards.
enum AwardFilter {
    case subAgency(SubAgencySpendingResult)
    case recipient(String)
    case pscAndRecipient(pscCode: String, recipientUei: String)
    case stateAndRecipient(stateCode: String, recipientUei: String)
    case industryAndRecipient(naicsCode: String, recipientUei: String)
    case covidRecipient(String) // New case for COVID-19 recipient awards
}

@MainActor
class AwardListViewModel: ObservableObject {
    @Published var awards: [AwardResult] = []
    @Published var viewState: LoadingState = .loading

    func fetchAwards(filter: AwardFilter, year: Int, quarter: Int) async {
        viewState = .loading
        do {
            let response: AwardSpendingResponse
            switch filter {
            case .subAgency(let subAgency):
                response = try await APIService.shared.fetchAwards(for: subAgency, fiscalYear: year, fiscalQuarter: quarter)
            case .recipient(let recipientId):
                response = try await APIService.shared.fetchAwards(for: recipientId, fiscalYear: year, fiscalQuarter: quarter)
            case .pscAndRecipient(let pscCode, let recipientUei):
                response = try await APIService.shared.fetchAwards(for: recipientUei, pscCode: pscCode, fiscalYear: year, fiscalQuarter: quarter)
            case .stateAndRecipient(let stateCode, let recipientUei):
                response = try await APIService.shared.fetchAwards(for: recipientUei, stateCode: stateCode, fiscalYear: year, fiscalQuarter: quarter)
            case .industryAndRecipient(let naicsCode, let recipientUei):
                response = try await APIService.shared.fetchAwards(for: recipientUei, naicsCode: naicsCode, fiscalYear: year, fiscalQuarter: quarter)
            case .covidRecipient(let recipientUei):
                response = try await APIService.shared.fetchCovidAwards(for: recipientUei, fiscalYear: year, fiscalQuarter: quarter)
            }
            self.awards = response.results
            viewState = .success
        } catch let error as APIError {
            viewState = .error(error.localizedDescription)
        } catch {
            viewState = .error("An unexpected error occurred.")
        }
    }
}

