import Foundation
import SwiftUI

enum TabSelection {
    case dashboard, agencies, explore, covid19, search // Added covid19
}

class NavigationViewModel: ObservableObject {
    @Published var selectedTab: TabSelection = .dashboard
    
    @Published var agencyDestination: AgencySpendingResult?
    @Published var pscDestination: PSC?
    @Published var recipientDestination: Recipient?

    func navigateToAgency(_ agency: AgencySpendingResult) {
        agencyDestination = agency
        selectedTab = .agencies
    }
    
    func navigateToPSC(_ psc: PSC) {
        pscDestination = psc
        selectedTab = .explore
    }
    
    func navigateToRecipient(_ recipient: Recipient) {
        recipientDestination = recipient
        selectedTab = .explore
    }
}

