//
//  PSCDetailView.swift
//  GovLedger
//


import SwiftUI

struct PSCDetailView: View {
    let psc: PSC
    
    var body: some View {
        List {
            Section(header: Text("Summary")) {
                Text(psc.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.vertical)
                
                HStack {
                    Text("Total Spending")
                    Spacer()
                    Text(psc.totalSpending, format: .currency(code: "USD"))
                }
            }
            
            Section(header: Text("Awards in this Category (Sample)")) {
                // In a real app, you would fetch and list awards for this PSC
                Text("Award for: \(psc.name) to AeroCorp")
                Text("Award for: \(psc.name) to TechLogistics")
            }
        }
        .navigationTitle("PSC Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
