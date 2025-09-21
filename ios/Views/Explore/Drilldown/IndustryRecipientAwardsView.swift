//
//  IndustryRecipientAwardsView.swift
//  GovSpendr
//

import SwiftUI

struct IndustryRecipientAwardsView: View {
    let industry: NAICSSpendingResult
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
            // Ensure we have the necessary IDs to make the API call
            guard let recipientUei = recipient.recipientUei else { return }
            
            // Call the ViewModel with the new, more specific filter
            await viewModel.fetchAwards(
                filter: .industryAndRecipient(naicsCode: industry.code, recipientUei: recipientUei),
                year: filters.selectedYear,
                quarter: filters.selectedQuarter
            )
        }
    }
}
