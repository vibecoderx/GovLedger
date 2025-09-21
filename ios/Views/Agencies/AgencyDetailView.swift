import SwiftUI

struct AgencyDetailView: View {
    let agency: AgencySpendingResult
    @EnvironmentObject var filters: FilterViewModel
    @StateObject private var viewModel = AgencyDetailViewModel()
    
    var body: some View {
        List {
            Section(header: Text("Summary")) {
                Text("Total Spending: \(agency.amount, format: .currency(code: "USD"))")
            }
            
            Section(header: Text("Sub-Agencies")) {
                switch viewModel.viewState {
                case .loading:
                    ProgressView("Loading Sub-Agencies...")
                case .success:
                    if viewModel.subAgencies.isEmpty {
                        Text("No sub-agency spending found for this period.")
                    } else {
                        ForEach(viewModel.subAgencies) { subAgency in
                            NavigationLink(value: subAgency) {
                                VStack(alignment: .leading) {
                                    Text(subAgency.name).font(.headline)
                                    Text(subAgency.amount, format: .currency(code: "USD").precision(.fractionLength(0)))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                case .error(let message):
                    Text("Error: \(message)")
                        .foregroundColor(.red)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(agency.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: SubAgencySpendingResult.self) { subAgency in
            SubAgencyAwardsView(subAgency: subAgency)
        }
        .task(id: "\(agency.id)-\(filters.selectedYear)-\(filters.selectedQuarter)") {
            await viewModel.fetchSubAgencies(for: agency, year: filters.selectedYear, quarter: filters.selectedQuarter)
        }
    }
}

