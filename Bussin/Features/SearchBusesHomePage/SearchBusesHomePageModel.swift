//
//  SearchBusesHomePageModel.swift
//  Bussin
//
//  Created by Matthew Tsang on 31/08/2024.
//

import Foundation

struct BusRoute: Identifiable, Equatable, Codable {
    let id: String // Composite ID - this is needed as multiple bus routes could have the same lineId
    let lineId: String // Bus line ID, e.g., "1", "10", etc.
    let operatorName: String
    let operatorNoc: String
    
    init(lineId: String, operatorName: String, operatorNoc: String) {
        self.lineId = lineId
        self.operatorName = operatorName
        self.operatorNoc = operatorNoc
        self.id = "\(lineId)-\(operatorNoc)" // Composite ID
    }
}
