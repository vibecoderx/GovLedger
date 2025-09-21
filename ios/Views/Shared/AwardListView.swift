import SwiftUI

struct AwardListView: View {
    let title: String
    let viewState: LoadingState
    let awards: [AwardResult]

    var body: some View {
        List {
            switch viewState {
            case .loading:
                ProgressView("Loading Awards...")
            case .success:
                if awards.isEmpty {
                    Text("No awards found for this category in the selected period.")
                } else {
                    ForEach(awards) { award in
                        NavigationLink(value: award) {
                            AwardRowView(award: award)
                        }
                    }
                }
            case .error(let message):
                Text("Error: \(message)").foregroundColor(.red)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AwardResult.self) { award in
            AwardDetailView(award: award)
        }
    }
}

// A helper view for a single award row to keep the main view clean.
struct AwardRowView: View {
    let award: AwardResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(award.recipientName)
                .font(.headline)
            
            Text(awardLocation(award))
                .font(.caption)
                .foregroundColor(.secondary)

            Text(award.awardAmount, format: .currency(code: "USD"))
                .font(.subheadline)
                .foregroundColor(.green)
            
            Text(award.description?.sentenceCased() ?? "No description provided.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
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
}
