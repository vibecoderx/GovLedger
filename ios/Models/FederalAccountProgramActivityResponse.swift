//
//  FederalAccountProgramActivityResponse.swift
//  GovSpendr
//

import Foundation

struct FederalAccountProgramActivityResponse: Decodable {
    let results: [ProgramActivityResult]
}

struct ProgramActivityResult: Decodable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let code: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case code = "code"
        case type = "type"
    }
}
