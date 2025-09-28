//
//  RecipientAwardsView.swift
//  GovLedger
//

import SwiftUI

struct RecipientAwardsView: View {
    let recipient: RecipientSpendingResult
    @StateObject private var viewModel = AwardListViewModel()
    @EnvironmentObject var filters: FilterViewModel

    var body: some View {
        AwardListView(
            title: recipient.name,
            viewState: viewModel.viewState,
            awards: viewModel.awards
        )
        .task {
            // Use the UEI for the search, as it's the correct unique identifier
            guard let recipientUei = recipient.recipientUei else { return }
            await viewModel.fetchAwards(
                filter: .recipient(recipientUei),
                year: filters.selectedYear,
                quarter: filters.selectedQuarter
            )
        }
    }
}

