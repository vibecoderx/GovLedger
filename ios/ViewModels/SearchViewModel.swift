import Foundation

// A struct to hold our search suggestions with an associated icon
struct SearchSuggestion: Identifiable {
    let id = UUID()
    let text: String
    let icon: String // SF Symbol name
}

@MainActor
class SearchViewModel: ObservableObject {
    @Published var awards: [AwardResult] = []
    @Published var viewState: LoadingState = .success // Start with a non-loading state
    @Published var searchText = ""
    @Published var hasPerformedSearch = false // Flag to track if a search has been initiated
    
    // A mix of interesting, standard, and fun search terms to spark curiosity
    let suggestions: [SearchSuggestion] = [
        SearchSuggestion(text: "F-35 Lightning II", icon: "airplane"),
        SearchSuggestion(text: "Artemis", icon: "moon.stars.fill"),
        SearchSuggestion(text: "Cybersecurity", icon: "lock.shield.fill"),
        SearchSuggestion(text: "National Parks", icon: "tree.fill"),
        SearchSuggestion(text: "Artificial Intelligence", icon: "brain.head.profile.fill"),
        SearchSuggestion(text: "Chicken Fajita", icon: "fork.knife"),
        SearchSuggestion(text: "Musical Instruments", icon: "guitars.fill"),
        SearchSuggestion(text: "James Webb Space Telescope", icon: "binoculars.circle.fill")
    ]

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


