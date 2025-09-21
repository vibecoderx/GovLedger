import Foundation
import SwiftUI

struct PSC: Identifiable, Hashable {
    let id: String
    let name: String
    let totalSpending: Double
    let color: Color // <-- Add property here
}
