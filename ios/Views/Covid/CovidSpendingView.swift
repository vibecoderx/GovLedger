//
//  CovidSpendingView.swift
//  GovSpendr
//

import SwiftUI

struct CovidSpendingView: View {
    @StateObject private var viewModel = CovidSpendingViewModel()
    @EnvironmentObject var filters: FilterViewModel
    
    @State private var selectedCategory: CovidCategory = .all

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(CovidCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                // The list content, which changes based on the picker and loading state
                switch viewModel.viewState {
                case .loading:
                    ProgressView("Loading...")
                        .frame(maxHeight: .infinity)
                case .success:
                    RecipientListView(
                        title: "Top COVID-19 Recipients",
                        viewState: viewModel.viewState,
                        recipients: viewModel.recipients,
                        multipleRecipientsAmount: viewModel.amountForMultipleRecipients
                    )
                    .navigationDestination(for: RecipientSpendingResult.self) { recipient in
                        CovidRecipientAwardsView(recipient: recipient)
                    }
                case .error(let message):
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        Text("Could Not Load Data")
                            .font(.headline)
                        Text(message)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationTitle("COVID-19 Spending")
            .toolbar {
                ToolbarItem(placement: .principal) { FiscalYearSelectorView() }
            }
            .task(id: "\(selectedCategory)-\(filters.selectedYear)-\(filters.selectedQuarter)") {
                await viewModel.fetchRecipients(for: selectedCategory, year: filters.selectedYear, quarter: filters.selectedQuarter)
            }
        }
    }
}

