//
//  RecipientListViewModel.swift
//  GovSpendr
//

import Foundation
import SwiftUI

/// An enum to define the different ways we can filter for recipients.
enum RecipientFilter {
    case psc(String)
    case state(String)
    case industry(String)
    case federalAccount(String)
}

@MainActor
class RecipientListViewModel: ObservableObject {
    @Published var recipients: [RecipientSpendingResult] = []
    @Published var amountForMultipleRecipients: Double = 0
    @Published var viewState: LoadingState = .loading

    func fetchRecipients(filter: RecipientFilter, year: Int, quarter: Int) async {
        viewState = .loading
        do {
            let response = try await APIService.shared.fetchRecipients(filter: filter, year: year, quarter: quarter)
            
            // Process the data to separate individual spending
            if let multipleRecipients = response.results.first(where: { $0.recipientId == nil }) {
                self.amountForMultipleRecipients = multipleRecipients.amount
            }
            self.recipients = response.results.filter { $0.recipientId != nil }

            viewState = .success
        } catch let error as APIError {
            viewState = .error(error.localizedDescription)
        } catch {
            viewState = .error("An unexpected error occurred.")
        }
    }
}

