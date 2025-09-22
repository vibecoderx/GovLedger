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
                     // Show suggestions when no search has been performed
                     VStack {
                        Text("Or try one of these suggestions:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.suggestions) { suggestion in
                                    Button(action: {
                                        viewModel.searchText = suggestion.text
                                        Task {
                                            await viewModel.searchAwards(year: filters.selectedYear, quarter: filters.selectedQuarter)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: suggestion.icon)
                                                .frame(width: 25, alignment: .center)
                                            Text(suggestion.text)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(10)
                                        .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding()
                        }
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
