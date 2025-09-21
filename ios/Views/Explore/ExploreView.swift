import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @EnvironmentObject var filters: FilterViewModel
    
    @State private var selectedCategory: ExploreCategory = .psc

    var body: some View {
        NavigationStack {
            VStack {
                // Picker for selecting the category
                Picker("Category", selection: $selectedCategory) {
                    ForEach(ExploreCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                // The list content, which changes based on the picker and loading state
                switch viewModel.viewState {
                case .loading:
                    ProgressView("Loading...")
                        .frame(maxHeight: .infinity)
                case .success:
                    contentView
                case .error(let message):
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        Text("Could Not Load Data")
                            .font(.headline)
                        Text(message)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItem(placement: .principal) { FiscalYearSelectorView() }
            }
            // Fetch data when the view appears or filters/category change
            .task(id: "\(selectedCategory)-\(filters.selectedYear)-\(filters.selectedQuarter)") {
                await viewModel.fetchData(for: selectedCategory, year: filters.selectedYear, quarter: filters.selectedQuarter)
            }
        }
    }
    
    // This ViewBuilder returns the correct list based on the selected category.
    @ViewBuilder
    private var contentView: some View {
        switch selectedCategory {
        case .psc:
            List(viewModel.pscCategories) { category in
                NavigationLink(value: category) {
                    HStack {
                        Text(category.name)
                        Spacer()
                        Text(category.amount, format: .currency(code: "USD").notation(.compactName))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationDestination(for: PSCChartData.self) { category in
                PSCRecipientsView(category: category)
            }
        case .recipient:
            List(viewModel.recipients) { recipient in
                NavigationLink(value: recipient) {
                    HStack {
                        Text(recipient.name)
                        Spacer()
                        Text(recipient.amount, format: .currency(code: "USD").notation(.compactName))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationDestination(for: RecipientSpendingResult.self) { recipient in
                RecipientAwardsView(recipient: recipient)
            }
        case .state:
            List(viewModel.states) { state in
                NavigationLink(value: state) {
                    HStack {
                        Text(state.name ?? "Unknown")
                        Spacer()
                        Text(state.amount, format: .currency(code: "USD").notation(.compactName))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationDestination(for: StateSpendingResult.self) { state in
                StateRecipientsView(state: state)
            }
        case .industry:
            List(viewModel.industries) { industry in
                NavigationLink(value: industry) {
                     VStack(alignment: .leading) {
                        Text(industry.name)
                            .font(.headline)
                        Text(industry.amount, format: .currency(code: "USD").notation(.compactName))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationDestination(for: NAICSSpendingResult.self) { industry in
                IndustryRecipientsView(industry: industry)
            }
        case .federalAccount:
            List(viewModel.federalAccounts) { account in
                NavigationLink(value: account) {
                    VStack(alignment: .leading) {
                        Text(account.name)
                            .font(.headline)
                        Text(account.amount, format: .currency(code: "USD").notation(.compactName))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationDestination(for: FederalAccountResult.self) { account in
                FederalAccountProgramActivitiesView(federalAccount: account)
            }
        }
    }
}

