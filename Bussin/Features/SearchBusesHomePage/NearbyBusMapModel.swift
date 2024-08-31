//
//  NearbyBusMapModel.swift
//  Bussin
//
//  Created by Matthew Tsang on 31/08/2024.
//

import Foundation
import SwiftUI
import MapKit

// Define the model for bus data
struct Bus: Identifiable, Codable {
    let id = UUID()
    let recordedAtTime: String
    let directionRef: String
    let publishedLineName: String
    let vehicleUniqueId: String
    let latitude: Double
    let longitude: Double
    let originRef: String
    let originName: String
    let destinationRef: String
    let destinationName: String
    let recordedMinutesAgo: Int

    // Coding keys for decoding from API response
    enum CodingKeys: String, CodingKey {
        case recordedAtTime = "recorded_at_time"
        case directionRef = "direction_ref"
        case publishedLineName = "published_line_name"
        case vehicleUniqueId = "vehicle_unique_id"
        case latitude
        case longitude
        case originRef = "origin_ref"
        case originName = "origin_name"
        case destinationRef = "destination_ref"
        case destinationName = "destination_name"
        case recordedMinutesAgo = "recorded_minutes_ago"
    }
}
