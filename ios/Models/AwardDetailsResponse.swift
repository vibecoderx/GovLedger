//
//  AwardDetailsResponse.swift
//  GovSpendr
//

import Foundation

// MARK: - Main Response Structure
struct AwardDetailsResponse: Decodable {
    let awardingAgency: AgencyX?
    let fundingAgency: AgencyX?
    let periodOfPerformance: PeriodOfPerformance?
    let typeDescription: String?
    let potentialTotalValue: Double?

    enum CodingKeys: String, CodingKey {
        case awardingAgency = "awarding_agency"
        case fundingAgency = "funding_agency"
        case periodOfPerformance = "period_of_performance"
        case typeDescription = "type_description"
        case potentialTotalValue = "total_obligation"
    }
}

// MARK: - Nested Structures
struct AgencyX: Decodable {
    let topTierAgency: AgencyDetailsX?
    let subTierAgency: AgencyDetailsX?
    let officeAgencyName: String?
    
    enum CodingKeys: String, CodingKey {
        case topTierAgency = "toptier_agency"
        case subTierAgency = "subtier_agency"
        case officeAgencyName = "office_agency_name"
    }
}

struct AgencyDetailsX: Decodable {
    let name: String
}

struct PeriodOfPerformance: Decodable {
    let startDate: String?
    let endDate: String?

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
    }
}
