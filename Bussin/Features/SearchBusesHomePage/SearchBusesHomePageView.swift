import SwiftUI

struct SearchBusLocationHomepageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> // able to use custom buttons to go back in navigation stacks
    @AppStorage("UserPostcode") private var storedPostcode: String = "AL1 1UJ"
    @AppStorage("AtcoAreaCode") private var storedAtcoAreaCode: String = ""
    @AppStorage("IsUserLocationLoaded") var isLocationLoaded: Bool = true
    @AppStorage("RecentRoutes") private var recentRoutes: Data = Data() // For storing recent routes

    @StateObject private var viewModel: BusRoutesViewModel

    init() { // Initialize ViewModel with stored AtcoAreaCode to get routes that run in this region
        _viewModel = StateObject(wrappedValue: BusRoutesViewModel(atcoAreaCode: UserDefaults.standard.string(forKey: "AtcoAreaCode") ?? ""))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(#colorLiteral(red: 0.1545608342, green: 0.3511599302, blue: 0.4604178071, alpha: 1)), Color(#colorLiteral(red: 0.101461418, green: 0.2473823726, blue: 0.3194232881, alpha: 1))],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack {

                    ZStack {

                        // Brown RoundedRectangle background
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Material.thin)
                            .frame(width: UIScreen.main.bounds.width, height: 150)

                        // Text and Button on top of the yellow background
                        VStack(spacing: 20) {
                            Text("Showing Results Near \(storedPostcode)")
                                .font(Font.custom("LexendDeca-SemiBold", size: 18))
                                .offset(x: 0, y: 13)

                            Button {
                                isLocationLoaded = false
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 5)
                                    .fill(Color.brown)
                                    .frame(width: 250, height: 40)
                                    .overlay(
                                        Text("Search Somewhere Else")
                                            .font(Font.custom("LexendDeca-Light", size: 16))
                                            .fontWeight(.medium)
                                            .foregroundColor(Color.white)
                                            .padding(10)
                                        )
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.top, 30)
                    }.ignoresSafeArea()

                    Spacer()

                    VStack { // Searchable TextField with a magnifying glass icon
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search buses", text: $viewModel.searchText)
                                .font(Font.custom("LexendDeca-SemiBold", size: 19))
                                .foregroundStyle(Color.black)
                        }
                        .padding()
                        .background(Color.white.opacity(0.88))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .padding(.top, -40)

                        // Show the list only when the user starts typing
                        if !viewModel.searchText.isEmpty {
                            BusRoutesListView(busRoutes: viewModel.filteredRoutes, saveRecent: saveRecentRoute)
                                .frame(width: UIScreen.main.bounds.width, height: 220)
                        } else {
                            RecentQueryView()
                        }
                        Spacer()
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }

    private func saveRecentRoute(_ route: BusRoute) {
        var recents = loadRecentRoutes()
        print("Recents: \(recents)")

        // Check for duplicates using the unique id
        if !recents.contains(where: { $0.id == route.id }) {
            recents.insert(route, at: 0)
            if recents.count > 2 {
                recents.removeLast()
            }

            if let data = try? JSONEncoder().encode(recents) {
                recentRoutes = data
                print("Decoded: \(recentRoutes)")
                print("Saved recent routes successfully.")
            }
        }
    }

    private func loadRecentRoutes() -> [BusRoute] {
        if let routes = try? JSONDecoder().decode([BusRoute].self, from: recentRoutes) {
            print("Loaded recent routes: \(routes.map { $0.id })")
            return routes
        }
        print("Failed to decode recent routes.")
        return []
    }
}


struct RouteDetailView: View {
    let route: BusRoute
    
    var body: some View {
        VStack {
            Text("Route: \(route.lineId)")
                .font(Font.custom("LexendDeca-Bold", size: 24))
                .padding()
            
            Text("Operator: \(route.operatorName)")
                .font(Font.custom("LexendDeca-Regular", size: 20))
                .padding(.top, 10)
            
            Text("Operator NOC: \(route.operatorNoc)")
                .font(Font.custom("LexendDeca-Regular", size: 20))
                .padding(.top, 10)
            
            Spacer()
        }
        .navigationTitle("\(route.lineId) - \(route.operatorName)")
    }
}

struct RecentQueryView: View {
    @AppStorage("RecentRoutes") private var recentRoutes: Data = Data()
    
    var body: some View {
        let routes = loadRecentRoutes()
        
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Image(systemName: "clock")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.white)
                    .opacity(0.9)
                    .padding(.leading)
                
                Text("Recents")
                    .foregroundStyle(Color.white)
                    .opacity(0.9)
                    .font(Font.custom("LexendDeca-SemiBold", size: 26))
                
                Spacer()
            }
            .padding(.top)
            
            // Display recent routes or a message if there are none
            if routes.isEmpty {
                Text("No recent routes.")
                    .font(Font.custom("LexendDeca-Regular", size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 10)
                    .padding(.horizontal)
            } else {
                ForEach(routes) { route in
                    
                    let busRoute = BusRoute(lineId: route.lineId, operatorName: route.operatorName, operatorNoc: route.operatorNoc)
                    
                    RecentRouteCard(route: busRoute)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("PrimaryColor"), Color.pink.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .padding()
        .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
    }
    
    private func loadRecentRoutes() -> [BusRoute] {
        if let routes = try? JSONDecoder().decode([BusRoute].self, from: recentRoutes) {
            return routes
        }
        print("No existing routes")
        return []
    }
}

struct RecentRouteCard: View {
    let route: BusRoute

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Route \(route.lineId)")
                    .font(Font.custom("LexendDeca-SemiBold", size: 18))
                    .foregroundColor(.black)

                Text("Operated by \(route.operatorName)")
                    .font(Font.custom("LexendDeca-Regular", size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()

            NavigationLink(destination: RouteDetailView(route: route)) {
                Image(systemName: "arrow.right.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color("SecondaryColor"))
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

struct BusRoutesListView: View {
    let busRoutes: [BusRoute]
    let saveRecent: (BusRoute) -> Void
    
    @State private var selectedRoute: BusRoute? = nil
    @State private var isNavigationActive: Bool = false

    var body: some View {
        VStack {
            if busRoutes.isEmpty {
                Text("No valid results in this area. Search other areas?")
                    .padding()
                    .font(Font.custom("LexendDeca-Light", size: 18))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(18)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    .padding(.vertical, 4)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        ForEach(busRoutes) { route in
                            Button {
                                print("Saving route as \(route.lineId)")
                                saveRecent(route)
                                selectedRoute = route
                                isNavigationActive = true
                            } label: {
                                Text("\(route.lineId) - \(route.operatorName)")
                                    .padding()
                                    .font(Font.custom("LexendDeca-SemiBold", size: 16))
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white.opacity(0.85))
                                    .cornerRadius(18)
                                    .padding(.horizontal)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .background(Color.clear)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.spring(duration: 0.15), value: busRoutes)
                
                // NavigationLink to handle navigation
                NavigationLink(
                    destination: RouteDetailView(route: selectedRoute ?? BusRoute(lineId: "", operatorName: "", operatorNoc: "")),
                    isActive: $isNavigationActive
                ) {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    SearchBusLocationHomepageView()
}
