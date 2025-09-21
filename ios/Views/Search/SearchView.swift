import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var filters: FilterViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    TextField("Search for awards...", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            Task {
                                await viewModel.searchAwards(year: filters.selectedYear, quarter: filters.selectedQuarter)
                            }
                        }
                        .onChange(of: viewModel.searchText) { _, newValue in
                            if newValue.isEmpty {
                                viewModel.hasPerformedSearch = false
                                viewModel.awards = []
                            }
                        }

                    Button(action: {
                        Task {
                            await viewModel.searchAwards(year: filters.selectedYear, quarter: filters.selectedQuarter)
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                    .padding(.leading, 5)
                }
                .padding()

                // Use the hasPerformedSearch flag to decide what to show
                if viewModel.hasPerformedSearch {
                    AwardListView(title: "Search Results", viewState: viewModel.viewState, awards: viewModel.awards)
                } else {
                     VStack {
                        Spacer()
                        Text("Enter a keyword to search for government awards.")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    FiscalYearSelectorView()
                }
            }
            .task(id: "\(filters.selectedYear)-\(filters.selectedQuarter)") {
                // Re-run search if filters change and a search has already been performed
                if viewModel.hasPerformedSearch {
                    await viewModel.searchAwards(year: filters.selectedYear, quarter: filters.selectedQuarter)
                }
            }
        }
    }
}
