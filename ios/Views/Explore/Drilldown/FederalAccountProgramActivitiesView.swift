//
//  FederalAccountProgramActivitiesView.swift
//  GovLedger
//

import SwiftUI

struct FederalAccountProgramActivitiesView: View {
    let federalAccount: FederalAccountResult
    @StateObject private var viewModel = FederalAccountProgramActivityViewModel()
    @EnvironmentObject var filters: FilterViewModel

    var body: some View {
        List {
            switch viewModel.viewState {
            case .loading:
                ProgressView("Loading Program Activities...")
            case .success:
                if viewModel.programActivities.isEmpty {
                    Text("No program activities found for this account in the selected period.")
                } else {
                    ForEach(viewModel.programActivities) { activity in
                        VStack(alignment: .leading) {
                            Text(activity.name)
                                .font(.headline)
                            Text("Code: \(activity.code)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(activity.type)
                                .font(.subheadline)

                        }
                        .padding(.vertical, 4)
                    }
                }
            case .error(let message):
                Text("Error: \(message)").foregroundColor(.red)
            }
        }
        .navigationTitle(federalAccount.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchProgramActivities(for: federalAccount.code, year: filters.selectedYear)
        }
    }
}
