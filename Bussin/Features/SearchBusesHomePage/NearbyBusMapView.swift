//
//  NearbyBusMapView.swift
//  Bussin
//
//  Created by Matthew Tsang on 31/08/2024.
//

import SwiftUI
import Foundation
import MapKit


struct NearbyBusMapView: View {
    @AppStorage("UserLatitude") var centerLatitude: Double = 51.6908
    @AppStorage("UserLongitude") var centerLongitude: Double = 0.206
    @State private var region: MKCoordinateRegion
    @State private var lastFetchedRegion: MKCoordinateRegion?
    @StateObject private var dataService = BusDataService()

    init() {
        let initialLocation = CLLocationCoordinate2D(
            latitude: UserDefaults.standard.double(forKey: "UserLatitude"),
            longitude: UserDefaults.standard.double(forKey: "UserLongitude")
        )
        _region = State(initialValue: MKCoordinateRegion(center: initialLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Buses Near You")
                .font(Font.custom("LexendDeca-SemiBold", size: 25))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.horizontal) // Padding to match other elements

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Material.thick)
                    .shadow(radius: 5)

                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: dataService.buses) { bus in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: bus.latitude, longitude: bus.longitude)) {
                        VStack {
                            Image(systemName: "bus.fill")
                                .foregroundColor(.blue)
                                .font(.title)
                            Text(bus.publishedLineName)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onAppear {
                    startMonitoringRegionChanges()
                }
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 300)
            .padding(.horizontal, 20)
        }
    }

    // Monitor for region changes using a timer-based approach
    private func startMonitoringRegionChanges() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Check if the region has significantly changed
            if let lastRegion = lastFetchedRegion, lastRegion.isApproximatelyEqual(to: region) {
                return // No significant change, no need to fetch
            }
            fetchBusData()
            lastFetchedRegion = region
        }
    }

    private func fetchBusData() {
        let minLat = region.center.latitude - region.span.latitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        let minLon = region.center.longitude - region.span.longitudeDelta / 2
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2
        dataService.fetchBuses(minLat: minLat, minLon: minLon, maxLat: maxLat, maxLon: maxLon)
    }
}

extension MKCoordinateRegion {
    // Custom comparison function to check if the region has significantly changed
    func isApproximatelyEqual(to other: MKCoordinateRegion, tolerance: Double = 0.0001) -> Bool {
        let latDiff = abs(center.latitude - other.center.latitude)
        let lonDiff = abs(center.longitude - other.center.longitude)
        let latSpanDiff = abs(span.latitudeDelta - other.span.latitudeDelta)
        let lonSpanDiff = abs(span.longitudeDelta - other.span.longitudeDelta)
        
        return latDiff < tolerance && lonDiff < tolerance && latSpanDiff < tolerance && lonSpanDiff < tolerance
    }
}

#Preview {
    NearbyBusMapView()
}
