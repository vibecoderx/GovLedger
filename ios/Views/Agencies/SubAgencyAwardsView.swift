import SwiftUI

struct SubAgencyAwardsView: View {
    @EnvironmentObject var filters: FilterViewModel
    let subAgency: SubAgencySpendingResult
    // FIX: Use the shared, robust AwardListViewModel instead of the buggy, specific one.
    @StateObject private var viewModel = AwardListViewModel()

    var body: some View {
        // Use the reusable AwardListView for a consistent UI.
        AwardListView(
            title: subAgency.name,
            viewState: viewModel.viewState,
            awards: viewModel.awards
        )
        .task {
            // Fetch awards using the appropriate filter case.
            await viewModel.fetchAwards(
                filter: .subAgency(subAgency),
                year: filters.selectedYear,
                quarter: filters.selectedQuarter
            )
        }
    }
}

#Preview {
    let mockSubAgency = SubAgencySpendingResult(name: "Federal Bureau of Investigation", amount: 50000000, parentAgency: "Department of Justice")
    
    return NavigationView {
        SubAgencyAwardsView(subAgency: mockSubAgency)
    }
    .environmentObject(FilterViewModel())
}

