import Foundation

// MARK: - LiveLocationTimetableMatched
struct LiveLocationTimetableMatched: Codable {
    let content: Content
    let remarks: String?
    let status: String
}

// MARK: - Content
struct Content: Codable {
    let busStops, closestStops: [Stop]
    let timetables: [Timetable]
    let vehicleLocations: VehicleLocations

    enum CodingKeys: String, CodingKey {
        case busStops = "bus_stops"
        case closestStops = "closest_stops"
        case timetables
        case vehicleLocations = "vehicle_locations"
    }
}

// MARK: - Stop
struct Stop: Codable {
    let stopID: String
    let stopLatitude, stopLongitude: Double
    let stopName: String

    enum CodingKeys: String, CodingKey {
        case stopID = "stop_id"
        case stopLatitude = "stop_latitude"
        case stopLongitude = "stop_longitude"
        case stopName = "stop_name"
    }
}

// MARK: - Timetable
struct Timetable: Codable {
    let direction: String
    let services: [Service]
}

// MARK: - Service
struct Service: Codable {
    let serviceArrivalTime: String
    let serviceOffset: Int
    let serviceOperatorName: String
    let serviceStops: [ServiceStop]

    enum CodingKeys: String, CodingKey {
        case serviceArrivalTime = "service_arrival_time"
        case serviceOffset = "service_offset"
        case serviceOperatorName = "service_operator_name"
        case serviceStops = "service_stops"
    }
}

// MARK: - ServiceStop
struct ServiceStop: Codable {
    let arrivalTime: String
    let majorStop: Bool
    let sequence: Int
    let stopPointID: String

    enum CodingKeys: String, CodingKey {
        case arrivalTime = "arrival_time"
        case majorStop = "major_stop"
        case sequence
        case stopPointID = "stop_point_id"
    }
}

// MARK: - VehicleLocations
struct VehicleLocations: Codable {
    let direction: String
    let vehicles: [Vehicle]
    
    enum CodingKeys: String, CodingKey {
     
        case direction
        case vehicles
    }
}


// MARK: - Vehicle
struct Vehicle: Codable {
    
    // service attributes
    let destinationID, destinationName: String
    let latitude, longitude: Double
    let nearestStops: [VehicleNearestStops?]
    let recordedMinutesAgo: Int
    let status: String?
    let timeDifferenceFromSchedule: Int?
    
    // vehicle attributes
    let make: String?
    let color: String?
    let vehicleUniqueID: String
    let isUniqueIDNumberPlate: Bool

    enum CodingKeys: String, CodingKey {
        case color
        case destinationID = "destination_id"
        case destinationName = "destination_name"
        case isUniqueIDNumberPlate = "is_unique_id_number_plate"
        case latitude, longitude, make
        case nearestStops = "nearest_stops"
        case recordedMinutesAgo = "recorded_minutes_ago"
        case status
        case timeDifferenceFromSchedule = "time_difference"
        case vehicleUniqueID = "vehicle_unique_id"
    }
}

struct VehicleNearestStops: Codable {
    
    let stopName: String
    let stopLatitude: Double
    let stopLongitude: Double
    let stopId: String
    
    enum CodingKeys: String, CodingKey {
        
        case stopName = "stop_name"
        case stopLatitude = "stop_latitude"
        case stopLongitude = "stop_longitude"
        case stopId = "stop_id"
        
    }
}

