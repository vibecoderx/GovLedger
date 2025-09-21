//
//  FiscalYearSelectorView.swift
//  GovSpendr
//


import SwiftUI

struct FiscalYearSelectorView: View {
    @EnvironmentObject var filters: FilterViewModel

    var body: some View {
        // A Menu acts as a dropdown container for our pickers
        Menu {
            // Picker for the Fiscal Year
            Picker("Fiscal Year", selection: $filters.selectedYear) {
                ForEach(filters.availableYears, id: \.self) { year in
                    Text("FY \(year)").tag(year)
                }
            }
            
            // Picker for the Quarter
            Picker("Quarter", selection: $filters.selectedQuarter) {
                ForEach(filters.quarters, id: \.self) { quarter in
                    if quarter == 0 {
                        Text("All Quarters").tag(quarter)
                    } else {
                        Text("Quarter \(quarter)").tag(quarter)
                    }
                }
            }
        } label: {
            // This is what the user sees on the navigation bar
            HStack {
                Text("FY \(filters.selectedYear.formatted(.number.grouping(.never))) - \(filters.quarterDisplayString)")
                Image(systemName: "chevron.down")
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationView {
        Text("Content")
            .navigationTitle("Preview")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    FiscalYearSelectorView()
                }
            }
    }
    .environmentObject(FilterViewModel())
}
