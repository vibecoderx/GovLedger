//
//  RecipientDetailView.swift
//  GovSpendr
//


import SwiftUI

struct RecipientDetailView: View {
    let recipient: Recipient
    
    var body: some View {
        List {
            Section(header: Text("Summary")) {
                Text(recipient.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.vertical)
                
                HStack {
                    Text("Total Received")
                    Spacer()
                    Text(recipient.totalSpending, format: .currency(code: "USD"))
                }
            }
            
            Section(header: Text("Awards Received by this Recipient (Sample)")) {
                // In a real app, you would fetch and list awards for this recipient
                Text("Award to \(recipient.name) from Dept. of Defense")
                Text("Award to \(recipient.name) from Dept. of Health")
            }
        }
        .navigationTitle("Recipient Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
