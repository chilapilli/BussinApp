import SwiftUI

struct SearchBusLocationHomepageView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @AppStorage("UserPostcode") private var storedPostcode: String = "AL1 1UJ"
    @State private var busRoute: String = ""
    @State private var showDropdown = false
    @State private var searchText = ""
    
    // Sample bus routes for search functionality
    let busRoutes = ["Bus 101", "Bus 102", "Bus 201", "Bus 202", "Express 301"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with gradient
                LinearGradient(colors: [Color(#colorLiteral(red: 0.1545608342, green: 0.3511599302, blue: 0.4604178071, alpha: 1)), Color(#colorLiteral(red: 0.101461418, green: 0.2473823726, blue: 0.3194232881, alpha: 1))],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack {
                    ZStack {
                        // Yellow RoundedRectangle background
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color(#colorLiteral(red: 0.9067086577, green: 0.6839393973, blue: 0.4260938764, alpha: 1)))
                            .frame(width: UIScreen.main.bounds.width, height: 170)
                            
                        
                        // Text and Button on top of the yellow background
                        VStack(spacing: 20) {
                            Text("Showing Results Near \(storedPostcode)")
                                .font(Font.custom("LexendDeca-SemiBold", size: 18))
                                .offset(x:0, y: 6)
                                
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.brown)
                                    .frame(width: 260, height: 50)
                                    .overlay(
                                        Text("Search Somewhere Else")
                                            .font(Font.custom("LexendDeca-Light", size: 16))
                                            .fontWeight(.medium)
                                            .foregroundColor(Color.white)
                                            .padding(10)
                                            .padding(.horizontal)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white, lineWidth: 3) // White outline around the text
                                            )
                                    )
                            }
                        }
                        .padding(.top, 30) // Adjust to fine-tune positioning
                    }.ignoresSafeArea()
                    
                    Spacer()
                    
                    VStack {
                        // Searchable TextField with a magnifying glass icon
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search buses", text: $searchText)
                                .font(Font.custom("LexendDeca-SemiBold", size: 19))
                                .foregroundStyle(Color.black)
                        }
                        .padding()
                        .background(Color.white.opacity(0.88))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .padding(.top, -25) // Adjust positioning closer to the yellow area
                        
                        // Show the list only when the user starts typing
                        if !searchText.isEmpty {
                            if searchResults.isEmpty {
                                // Display a message when no valid results are found
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
                                    ForEach(searchResults, id: \.self) { route in
                                        NavigationLink(destination: RouteDetailView(route: route)) {
                                            Text(route)
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
                                .background(Color.clear)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                                .transition(.opacity.combined(with: .move(edge: .top))) // Smooth transition effect
                                .animation(.easeInOut(duration: 0.15), value: searchText) // Animation for appearing and disappearing
                            }
                        }
                        
                        Spacer()
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
    
    // Filtered search results based on the user's input
    var searchResults: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return busRoutes.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct RouteDetailView: View {
    let route: String
    
    var body: some View {
        VStack {
            Text(route)
                .font(Font.custom("LexendDeca-Bold", size: 24))
                .padding()
            Spacer()
        }
        .navigationTitle(route)
    }
}

#Preview {
    SearchBusLocationHomepageView()
}
