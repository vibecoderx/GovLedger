//
//  SettingsView.swift
//  GovSpendr
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    // Formatter for currency input
    private var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personalize"), footer: Text("This value is used to estimate your personal contribution to specific government awards.")) {
                    HStack {
                        Text("My Annual Federal Tax")
                        Spacer()
                        TextField("$5,000", value: $settings.taxContribution, formatter: currencyFormatter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Settings")
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
