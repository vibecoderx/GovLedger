import SwiftUI

struct AwardDetailView: View {
    let award: AwardResult
    @StateObject private var viewModel = AwardDetailViewModel()
    @EnvironmentObject var filters: FilterViewModel // Inject the filters

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView("Loading Details...")
            case .success:
                List {
                    summarySection
                    awardingAgencySection
                    fundingAgencySection
                    detailsSection
                    subawardsSection
                }
            case .error(let message):
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                    Text("Error")
                        .font(.headline)
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Award Details")
        .navigationBarTitleDisplayMode(.inline)
        // Update the task to pass the selected fiscal period to the ViewModel
        .task {
            if let internalId = award.generatedInternalId {
                await viewModel.fetchAllAwardData(
                    for: internalId,
                    fiscalYear: filters.selectedYear,
                    fiscalQuarter: filters.selectedQuarter
                )
            }
        }
    }
    
    // MARK: - View Sections
    
    private var summarySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text(award.recipientName)
                    .font(.title2).bold()
                
                Text(awardLocation(award))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(award.awardAmount, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundColor(.green)
                
                // NEW: Display the calculated spending for the selected fiscal period
                if let amountInPeriod = viewModel.obligatedAmountInPeriod {
                    Divider()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Obligated in \(fiscalPeriodLabel())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(amountInPeriod, format: .currency(code: "USD"))
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                    .padding(.top, 4)
                }
                
                Text(award.description?.sentenceCased() ?? "No description provided.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                if let internalId = award.generatedInternalId,
                   let url = URL(string: "https://www.usaspending.gov/award/\(internalId)") {
                    Link("View on USAspending.gov", destination: url)
                        .font(.caption)
                        .padding(.top, 4)
                }
            }
            .padding(.vertical)
        } header: {
            Text("Summary").font(.headline)
        }
    }
    
    @ViewBuilder
    private var awardingAgencySection: some View {
        if let agency = viewModel.awardDetails?.awardingAgency {
            Section {
                if let topTier = agency.topTierAgency?.name, !topTier.isEmpty {
                    DetailRow(title: "Top-Tier Agency", value: topTier)
                }
                if let subTier = agency.subTierAgency?.name, !subTier.isEmpty {
                    DetailRow(title: "Sub-Tier Agency", value: subTier)
                }
                if let office = agency.officeAgencyName, !office.isEmpty {
                    DetailRow(title: "Office", value: office)
                }
            } header: {
                Text("Awarding Agency").font(.headline)
            }
        }
    }

    @ViewBuilder
    private var fundingAgencySection: some View {
        if let agency = viewModel.awardDetails?.fundingAgency {
            Section {
                if let topTier = agency.topTierAgency?.name, !topTier.isEmpty {
                    DetailRow(title: "Top-Tier Agency", value: topTier)
                }
                if let subTier = agency.subTierAgency?.name, !subTier.isEmpty {
                    DetailRow(title: "Sub-Tier Agency", value: subTier)
                }
                if let office = agency.officeAgencyName, !office.isEmpty {
                    DetailRow(title: "Office", value: office)
                }
            } header: {
                Text("Funding Agency").font(.headline)
            }
        }
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        if let details = viewModel.awardDetails {
            Section {
                DetailRow(title: "Award Type", value: details.typeDescription ?? "N/A")
                DetailRow(title: "Period of Performance", value: performancePeriod(details.periodOfPerformance))
                DetailRow(title: "Potential Total Value", value: details.potentialTotalValue?.formatted(.currency(code: "USD")) ?? "N/A")
            } header: {
                Text("Official Award Details").font(.headline)
            }
        }
    }

    private var subawardsSection: some View {
        Section {
            if viewModel.subawards.isEmpty {
                Text("No subawards found for this award.")
            } else {
                ForEach(viewModel.subawards) { subaward in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subaward.recipientName ?? "Unknown Recipient")
                            .font(.headline)
                        Text(subaward.amount ?? 0, format: .currency(code: "USD"))
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Text(subaward.actionDate ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(subaward.description?.sentenceCased() ?? "")
                             .font(.subheadline)
                             .foregroundColor(.secondary)
                             .lineLimit(5)
                    }
                    .padding(.vertical, 6)
                }
            }
        } header: {
            Text("Subawards").font(.headline)
        }
    }

    // MARK: - Helper Functions & Views
    
    // NEW: Helper to create a dynamic label for the fiscal period
    private func fiscalPeriodLabel() -> String {
        if filters.selectedQuarter == 0 {
            return "FY \(filters.selectedYear.formatted(.number.grouping(.never)))"
        } else {
            return "FY \(filters.selectedYear.formatted(.number.grouping(.never))) Q\(filters.selectedQuarter)"
        }
    }
    
    private func awardLocation(_ award: AwardResult) -> String {
        var locationParts: [String] = []
        if let state = award.state, !state.isEmpty {
            locationParts.append(state)
        }
        if let country = award.country, !country.isEmpty {
            locationParts.append(country)
        }
        return locationParts.joined(separator: ", ")
    }
    
    private func performancePeriod(_ period: PeriodOfPerformance?) -> String {
        guard let period = period, let start = period.startDate, let end = period.endDate else {
            return "N/A"
        }
        return "\(start) to \(end)"
    }
    
    struct DetailRow: View {
        let title: String
        let value: String

        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 4)
        }
    }
}

