//
//  AboutView.swift
//  GovSpendr
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 20) {
                        Image("GovSpendr_eagle_cash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(radius: 5)
                        
                        Text("GovLedger")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(AppInfoHelper.versionInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // NEW: Display the Git Commit SHA
                        Text("Commit: \(AppInfoHelper.gitCommitSHA)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                Section(header: Text("Data Source")) {
                    Text("This app uses data provided by USASpending.gov, the official source of US government spending data.")
                    if let url = URL(string: "https://www.usaspending.gov") {
                        Link("Visit USASpending.gov Website", destination: url)
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

