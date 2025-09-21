import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var awards: [AwardResult] = []
    @Published var viewState: LoadingState = .success // Start with a non-loading state
    @Published var searchText = ""
    @Published var hasPerformedSearch = false // Flag to track if a search has been initiated

    func searchAwards(year: Int, quarter: Int) async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.awards = []
            self.hasPerformedSearch = false // Reset if search text is cleared
            return
        }

        hasPerformedSearch = true // Mark that a search has been performed
        viewState = .loading
        do {
            let response = try await APIService.shared.fetchAwards(keyword: searchText, fiscalYear: year, fiscalQuarter: quarter)
            self.awards = response.results
            viewState = .success
        } catch let error as APIError {
            viewState = .error(error.localizedDescription)
        } catch {
            viewState = .error("An unexpected error occurred.")
        }
    }
}
