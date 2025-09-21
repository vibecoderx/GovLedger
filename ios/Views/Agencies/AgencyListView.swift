import SwiftUI

struct AgencyListView: View {
    @EnvironmentObject var navigation: NavigationViewModel
    @EnvironmentObject var filters: FilterViewModel
    @StateObject private var viewModel = AgencyListViewModel()

    var body: some View {
        NavigationStack {
            contentView // Use the helper view here
                .navigationTitle("Top-Tier Agencies")
                .toolbar {
                    ToolbarItem(placement: .principal) { FiscalYearSelectorView() }
                }
                .navigationDestination(for: AgencySpendingResult.self) { agency in
                    AgencyDetailView(agency: agency)
                }
                .navigationDestination(isPresented: Binding(
                    get: { navigation.agencyDestination != nil },
                    set: { if !$0 { navigation.agencyDestination = nil } }
                )) {
                    if let agency = navigation.agencyDestination {
                        AgencyDetailView(agency: agency)
                    }
                }
        }
        .task(id: "\(filters.selectedYear)-\(filters.selectedQuarter)") {
            await viewModel.fetchAgencies(year: filters.selectedYear, quarter: filters.selectedQuarter)
        }
    }
    
    /// A helper computed property to build the main content view.
    /// This resolves the compiler issue with applying modifiers to a switch statement.
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView("Loading Agencies...")
        
        case .success:
            List(viewModel.agencies) { agency in
                NavigationLink(value: agency) {
                    VStack(alignment: .leading) {
                        Text(agency.name).font(.headline)
                        Text(agency.amount, format: .currency(code: "USD").precision(.fractionLength(0)))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

        case .error(let message):
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                Text("Could Not Load Agencies")
                    .font(.headline)
                Text(message)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    AgencyListView()
        .environmentObject(NavigationViewModel())
        .environmentObject(FilterViewModel())
}

