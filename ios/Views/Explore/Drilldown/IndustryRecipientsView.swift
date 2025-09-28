//
//  IndustryRecipientsView.swift
//  GovLedger
//

import SwiftUI

struct IndustryRecipientsView: View {
    let industry: NAICSSpendingResult
    @StateObject private var viewModel = RecipientListViewModel()
    @EnvironmentObject var filters: FilterViewModel

    var body: some View {
        RecipientListView(
            title: industry.name,
            viewState: viewModel.viewState,
            recipients: viewModel.recipients,
            multipleRecipientsAmount: viewModel.amountForMultipleRecipients
        )
        // This view will now navigate to our new, specific awards view
        .navigationDestination(for: RecipientSpendingResult.self) { recipient in
            IndustryRecipientAwardsView(industry: industry, recipient: recipient)
        }
        .task {
            await viewModel.fetchRecipients(
                filter: .industry(industry.code),
                year: filters.selectedYear,
                quarter: filters.selectedQuarter
            )
        }
    }
}

