//
//  NearbyBusMapViewModel.swift
//  Bussin
//
//  Created by Matthew Tsang on 31/08/2024.
//


import Combine
import Foundation

class BusDataService: ObservableObject {
    @Published var buses: [Bus] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchBuses(minLat: Double, minLon: Double, maxLat: Double, maxLon: Double) {
        let urlString = "http://localhost:5000/vehicle_location_bounding_box?min_lat=\(minLat)&min_lon=\(minLon)&max_lat=\(maxLat)&max_lon=\(maxLon)"
            print(urlString)
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Bus].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fetchedBuses in
                self?.buses = fetchedBuses
            }
            .store(in: &cancellables)
    }
}
