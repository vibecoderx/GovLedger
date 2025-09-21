//
//  PSCRecipientsView.swift
//  GovSpendr
//

import SwiftUI

struct PSCRecipientsView: View {
    let category: PSCChartData
    @StateObject private var viewModel = RecipientListViewModel()
    @EnvironmentObject var filters: FilterViewModel

    var body: some View {
        RecipientListView(
            title: category.name,
            viewState: viewModel.viewState,
            recipients: viewModel.recipients,
            multipleRecipientsAmount: viewModel.amountForMultipleRecipients
        )
        // This is the CORRECT navigation destination that will now be used.
        .navigationDestination(for: RecipientSpendingResult.self) { recipient in
            PSCRecipientAwardsView(pscCategory: category, recipient: recipient)
        }
        .task {
            await viewModel.fetchRecipients(
                filter: .psc(category.code),
                year: filters.selectedYear,
                quarter: filters.selectedQuarter
            )
        }
    }
}
