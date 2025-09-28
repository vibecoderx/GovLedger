//
//  RecipientListView.swift
//  GovLedger
//


import SwiftUI

struct RecipientListView: View {
    let title: String
    let viewState: LoadingState
    let recipients: [RecipientSpendingResult]
    let multipleRecipientsAmount: Double

    var body: some View {
        List {
            switch viewState {
            case .loading:
                ProgressView("Loading Recipients...")
            case .success:
                if recipients.isEmpty {
                    Text("No organizational recipients found for this category.")
                } else {
                    ForEach(recipients) { recipient in
                        NavigationLink(value: recipient) {
                            HStack {
                                Text(recipient.name)
                                Spacer()
                                Text(recipient.amount, format: .currency(code: "USD").notation(.compactName))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                if multipleRecipientsAmount > 0 {
                    Section(header: Text("Other Spending")) {
                        individualSpendingRow
                    }
                }
                
            case .error(let message):
                Text("Error: \(message)").foregroundColor(.red)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        // This is the FIX: The conflicting .navigationDestination has been removed.
    }
    
    private var individualSpendingRow: some View {
        HStack {
            Image(systemName: "person.3.fill")
                .foregroundColor(.secondary)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Spending to Individuals")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(multipleRecipientsAmount, format: .currency(code: "USD").notation(.compactName))
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
    }
}
