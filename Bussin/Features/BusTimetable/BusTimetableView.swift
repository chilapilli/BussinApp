//
//  BusTimetableView.swift
//  Bussin
//
//  Created by Matthew Tsang on 01/09/2024.
//

import SwiftUI
import MapKit

struct RouteDetailView: View {
    @StateObject private var viewModel: MapViewModel
    @State private var showDirections: Bool = false

    init(busRoute: BusRoute) {
        _viewModel = StateObject(wrappedValue: MapViewModel(busRoute: busRoute))
    }

    var body: some View {
        VStack {
            Map(coordinateRegion: $viewModel.region, annotationItems: busLocations) { annotation in
                MapPin(coordinate: annotation.coordinate, tint: .blue)
            }
            .frame(height: 300)

            if let timetable = viewModel.currentTimetable {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(timetable.keys.sorted(), id: \.self) { stopPoint in
                            VStack {
                                Text(stopPoint)
                                Text(timetable[stopPoint] ?? "N/A")
                            }
                            .padding()
                        }
                    }
                }
                .frame(height: 100)
                .background(Color.gray.opacity(0.1))
            }

            HStack {
                Button("Previous") {
                    viewModel.decrementOffset()
                }
                .disabled(viewModel.currentOffset == 0)

                Spacer()

                Button("Next") {
                    viewModel.incrementOffset()
                }
                .disabled(viewModel.currentOffset >= (viewModel.maxOffset(for: viewModel.selectedDirection ?? "") ?? 0))
            }
            .padding()

            if showDirections {
                VStack {
                    Picker("Select Direction", selection: $viewModel.selectedDirection) {
                        ForEach(viewModel.allDirections, id: \.self) { direction in
                            Text(direction).tag(direction)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
            }

            Button(action: {
                showDirections.toggle()
            }) {
                Text(showDirections ? "Hide Directions" : "Show Directions")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }

    private var busLocations: [CustomAnnotation] {
        guard let timetable = viewModel.timetable else { return [] }

        var annotations: [CustomAnnotation] = []

        for (_, routeDetailsArray) in timetable.directionTimetables {
            for routeDetails in routeDetailsArray {
                // Assuming routeDetails has a property that gives bus location coordinates
                // For demonstration, we'll just use the stop points' coordinates for annotations
                for stopPoint in routeDetails.stopPoints {
                    if let stop = timetable.stopPoints?[stopPoint] {
                        let annotation = CustomAnnotation(
                            coordinate: CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude),
                            title: stop.commonName
                        )
                        annotations.append(annotation)
                    }
                }
            }
        }
        return annotations
    }
}

//
//struct RouteDetailView: View {
//    let route: BusRoute
//    
//    var body: some View {
//        VStack {
//            Text("Route: \(route.lineId)")
//                .font(Font.custom("LexendDeca-Bold", size: 24))
//                .padding()
//            
//            Text("Operator: \(route.operatorName)")
//                .font(Font.custom("LexendDeca-Regular", size: 20))
//                .padding(.top, 10)
//            
//            Text("Operator NOC: \(route.operatorNoc)")
//                .font(Font.custom("LexendDeca-Regular", size: 20))
//                .padding(.top, 10)
//            
//            Spacer()
//        }
//        .navigationTitle("\(route.lineId) - \(route.operatorName)")
//    }
//}


struct CustomAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
}

#Preview {
    RouteDetailView(busRoute: BusRoute(lineId: "84", operatorName: "Sullivan Buses", operatorNoc: "SULV"))
}
