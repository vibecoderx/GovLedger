//
//  CovidRecipientAwardsView.swift
//  GovSpendr
//


import SwiftUI

struct CovidRecipientAwardsView: View {
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
            
            // Call the ViewModel with the new, specific filter for COVID awards
            await viewModel.fetchAwards(
                filter: .covidRecipient(recipientUei),
                year: filters.selectedYear,
                quarter: filters.selectedQuarter
            )
        }
    }
}
