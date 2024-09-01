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
    @State private var selectedBusID: String? = nil
    @State private var isFetchingVehicleInfo: Bool = true
    @State var fetchingText: String = "Our scout is finding a bus there"
    @State var fetchingIcon: String = "figure.run"
    @State var noBusText: String = "Oops! Our scout didn't find any bus there 😥"
    @State var noBusIcon: String = "location.slash"
    
    init() {
        let initialLocation = CLLocationCoordinate2D(
            latitude: UserDefaults.standard.double(forKey: "UserLatitude"),
            longitude: UserDefaults.standard.double(forKey: "UserLongitude")
        )
        _region = State(initialValue: MKCoordinateRegion(center: initialLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Buses Near You")
                .font(Font.custom("LexendDeca-SemiBold", size: 25))
                .foregroundColor(.white)
                .padding(.horizontal, 16)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Material.thick)
                    .shadow(radius: 8)

                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: dataService.buses) { bus in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: bus.latitude, longitude: bus.longitude)) {
                        VStack(spacing: 4) {
                            Button(action: {
                                selectedBusID = selectedBusID == bus.vehicleUniqueId ? nil : bus.vehicleUniqueId
                            }) {
                                if selectedBusID == bus.vehicleUniqueId {
                                    SelectedBusView(bus: bus)
                                } else {
                                    NonSelectedBusView(bus: bus)
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic, showsTraffic: true))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onAppear {
                    startMonitoringRegionChanges()
                }
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 300)
            .padding(.horizontal, 20)
            .overlay(
                Group {
                    if isFetchingVehicleInfo {
                        ZStack {
                               
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(1.5)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(20)
                                .shadow(radius: 10)
                        }
                    }
                }
            )

            // Horizontal Scroll View for Bus Cards
            ScrollView(.horizontal, showsIndicators: false) {
                
                LazyHStack(spacing: 16) {
                    if isFetchingVehicleInfo {
                        
                        CardViewWhenUnavailable(unavailableText: $fetchingText, unavailableImageName: $fetchingIcon)
                        
                    } else if dataService.buses.isEmpty {
                        CardViewWhenUnavailable(unavailableText: $noBusText, unavailableImageName: $noBusIcon)
                    } else {
                        ForEach(dataService.buses, id: \.vehicleUniqueId) { bus in
                            BusCardView(bus: bus)
                                .frame(width: UIScreen.main.bounds.width - 40, height: 150) // Define the width here
                                .padding(.vertical, 10) // Add some vertical padding for better look
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 20) // Padding around the LazyHStack
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(height: 170) // Set the frame height for the scroll view
        }
    }

    // Monitor for region changes using a timer-based approach
    private func startMonitoringRegionChanges() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Check if the region has significantly changed
            if let lastRegion = lastFetchedRegion, lastRegion.isApproximatelyEqual(to: region) {
                return // No significant change, no need to fetch
            }
            DispatchQueue.main.async {
                isFetchingVehicleInfo = true
            }
            print("is fetching vehicle loaction before fetching: \(isFetchingVehicleInfo)")
            fetchBusData()
            lastFetchedRegion = region
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isFetchingVehicleInfo = false
            } // as the loading indicator don't show up if it is moved too fast
            
            print("is fetching vehicle loaction after fetching: \(isFetchingVehicleInfo)")
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

struct NonSelectedBusView: View {
    
    let bus: Bus
    
    var body: some View {
        VStack(spacing: 2) {
            
            Image(systemName: "bus.fill")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
            
            Text(bus.publishedLineName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(6)
        .background(Color.white.opacity(0.8))
        .cornerRadius(8)
    }
}

struct SelectedBusView: View {
    
    let bus: Bus
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "bus.fill")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
            
            VStack(spacing: 2) {
                Text(bus.publishedLineName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(bus.destinationName)
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                if bus.recordedMinutesAgo == 0 {
                    Text("Now")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                } else{
                    Text("\(bus.recordedMinutesAgo) minutes ago")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            .padding(6)
            .background(Color.blue.opacity(0.8))
            .cornerRadius(8)
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 1, y: 2)
    }
}

struct BusCardView: View {
    let bus: Bus
    
    var body: some View {
        GeometryReader { geometry in // Use GeometryReader to dynamically get width
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "bus.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                        .padding(.trailing, 10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bus.publishedLineName)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                        
                        Text("From: \(bus.originName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("To: \(bus.destinationName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(bus.recordedMinutesAgo == 0 ? "Now" : "\(bus.recordedMinutesAgo) minutes ago")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                }
                .padding()
            }
            .frame(width: geometry.size.width)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 150)
    }
}

struct CardViewWhenUnavailable: View {
    
    @Binding var unavailableText: String
    @Binding var unavailableImageName: String
    var body: some View{
        
        GeometryReader { geometry in // Use GeometryReader to dynamically get width
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: unavailableImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                        .padding(.trailing, 10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(unavailableText)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                        
                    }
                    
                    Spacer()
                    
                }
                .padding()
            }
            .frame(width: geometry.size.width)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 150)
        
        
    }
    
}

#Preview {
    NearbyBusMapView()
}
