//
//  PSCChartData.swift
//  GovSpendr
//


import Foundation
import SwiftUI

/// A processed data structure for displaying aggregated PSC spending in charts and lists.
struct PSCChartData: Identifiable, Hashable {
    /// The ID is the PSC code itself, which is unique for this aggregation level.
    var id: String { code }
    
    let code: String
    let name: String
    let amount: Double
    var color: Color
}
