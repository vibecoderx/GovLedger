//
//  PSCRecipientAwardsView.swift
//  GovSpendr
//

import SwiftUI

struct PSCRecipientAwardsView: View {
    let pscCategory: PSCChartData
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
            guard let recipientUei = recipient.recipientUei else { return }
            await viewModel.fetchAwards(
                filter: .pscAndRecipient(pscCode: pscCategory.code, recipientUei: recipientUei),
                year: filters.selectedYear,
                quarter: filters.selectedQuarter
            )
        }
    }
}

