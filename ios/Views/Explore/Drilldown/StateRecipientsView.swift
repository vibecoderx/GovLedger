//
//  StateRecipientsView.swift
//  GovSpendr
//

import SwiftUI

struct StateRecipientsView: View {
    let state: StateSpendingResult
    @StateObject private var viewModel = RecipientListViewModel()
    @EnvironmentObject var filters: FilterViewModel

    var body: some View {
        RecipientListView(
            title: state.name ?? "Unknown State",
            viewState: viewModel.viewState,
            recipients: viewModel.recipients,
            multipleRecipientsAmount: viewModel.amountForMultipleRecipients
        )
        // This view will navigate to the new, specific awards view when a recipient is tapped
        .navigationDestination(for: RecipientSpendingResult.self) { recipient in
            StateRecipientAwardsView(state: state, recipient: recipient)
        }
        .task {
            // Ensure we have a state code to filter by
            guard let stateCode = state.code else { return }
            await viewModel.fetchRecipients(
                filter: .state(stateCode),
                year: filters.selectedYear,
                quarter: filters.selectedQuarter
            )
        }
    }
}

