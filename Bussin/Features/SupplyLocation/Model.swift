//
//  Model.swift
//  Bussin
//
//  Created by Matthew Tsang on 30/08/2024.
//

import Foundation

// MARK: - UserLocation
struct UserLocationModel: Codable {
    
    let administrativeAreaCode, atcoAreaCode, easting: Int
    let localityName, name: String
    let northing: Int
    let nptgLocalityCode, qualiferName, shortName: String?
    let latitude, longitude: Double
    let postcode: String
    let remarks: String?

    enum CodingKeys: String, CodingKey {
        case administrativeAreaCode = "AdministrativeAreaCode"
        case atcoAreaCode = "AtcoAreaCode"
        case easting = "Easting"
        case localityName = "LocalityName"
        case name = "Name"
        case northing = "Northing"
        case nptgLocalityCode = "NptgLocalityCode"
        case qualiferName = "QualiferName"
        case shortName = "ShortName"
        case latitude, longitude, postcode, remarks
    }
}


