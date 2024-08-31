//  SwiftUIView.swift
//  Bussin
//
//  Created by Matthew Tsang on 29/08/2024.
//

import SwiftUI


// Mark: Main Screen
struct SupplyLocationView: View {
    /*
     Displayed when user first launches the app/ chooses to change location
     */
    @State private var userPostcode: String = "" // for storing the user postcode in the text field
    
    @State private var showLocationUnavailableSheet: Bool = false // for popup sheet
    @State private var isLoadingLocation: Bool = false
    @State private var isLoadingPostcode: Bool = false
    @State private var isServiceDisabled: Bool = false // when the location detected is outside the UK, disable location button
    @State private var isUserLocationLoaded: Bool = false // disable both buttons when loaction loaded
    @State private var isNavigating: Bool = false // State for managing navigation
        
    @StateObject private var viewModel = LocationViewModel() // core module use to get user location
    
    
    @State private var titleText: String = "Bussin'"
    @State private var tagLineText: String = "Track and Go!"
    
    var body: some View {
    
        NavigationStack {
            ZStack {
            
                GradientBackgroundView()
        
                VStack(alignment: .center, spacing: 10) {
                    Spacer()
                
                    BusImageView()
                    TitleTextView(titleText: $titleText)
                    TaglineTextView(tagLineText: $tagLineText)
                    
                    Spacer()
                    
                    ShareLocationButton(
                        locViewModel: viewModel,
                        isLoadingLocation: $isLoadingLocation,
                        showLocationUnavailableSheet: $showLocationUnavailableSheet,
                        isServiceDisabled: $isServiceDisabled,
                        isUserLocationLoaded: $isUserLocationLoaded
                    )
                    .sheet(
                        isPresented: $showLocationUnavailableSheet,
                        onDismiss: {
                            isServiceDisabled = true // Ensure that the service is still marked as disabled when the sheet is dismissed
                        },
                        content: {
                            ContentUnavailableView(
                                "Service Unavailable",
                                systemImage: "location.slash",
                                description: Text("Support for non-UK locations are unavailable.")
                            )
                        }
        
                    )
                    PostcodeTextField(locViewModel: viewModel,
                                      userPostcode: $userPostcode,
                                      isLoadingPostcode: $isLoadingPostcode,
                                      showLocationUnavailableSheet: $showLocationUnavailableSheet,
                                      isUserLocationLoaded: $isUserLocationLoaded )
                    .sheet(
                        isPresented: $showLocationUnavailableSheet,
                        onDismiss: {
                            isServiceDisabled = false // so that user can still use the current location button
                        },
                        content: {
                            ContentUnavailableView(
                                "Invalid Location",
                                systemImage: "location.slash",
                                description: Text("Try again with a valid postcode.")
                            )
                        }
                    )
                }
                .padding()
                .padding(.top)
                .alert(isPresented: $viewModel.locationPermissionDenied) {
                    Alert(
                        title: Text("Location Access Denied"),
                        message: Text("Please enable location services for this app in Settings. Go to Settings > Privacy > Location Services > Your App."),
                        primaryButton: .default(Text("Open Settings")) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .onChange(of: isUserLocationLoaded) { _ in
                        if isUserLocationLoaded {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isNavigating = true
                            }
                        }
                    }
                .navigationDestination(isPresented: $isNavigating) {
                    SearchBusLocationHomepageView()
                }
            }
        }
            }
        }
    
// MARK: - Components

struct BusImageView: View {
    @State private var imageScale: CGFloat = 1.0 // Start at the final scale
    @State private var shouldAnimate: Bool = false

    var body: some View {
        Image(systemName: "bus.doubledecker.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.black)
            .frame(width: 100, height: 100)
            .scaleEffect(shouldAnimate ? 1.0 : 0.8) // Set the starting scale smaller
            .shadow(radius: 4)
            .animation(shouldAnimate ? .interpolatingSpring(stiffness: 100, damping: 5).delay(0.2) : .none, value: shouldAnimate)
            .onAppear {
                shouldAnimate = true // Trigger the animation when view appears
            }
    }
}

struct TitleTextView: View {
    
    @Binding var titleText: String
    
    var body: some View {
        Text(titleText)
            .font(Font.custom("LexendDeca-SemiBold", size: 60))
            .shadow(radius: 2)
            .foregroundColor(.black)
    }
}

struct TaglineTextView: View {
    
    @Binding var tagLineText: String
    @State private var textOffset: CGFloat = 300
    
    var body: some View {
        Text(tagLineText)
            .font(Font.custom("LexendDeca-Light", size: 30))
            .frame(width: UIScreen.main.bounds.size.width * 0.8, alignment: .center)
            .opacity(0.7)
            .offset(y: textOffset)
            .animation(.interactiveSpring(duration: 0.4), value: textOffset)
            .onAppear {
                textOffset = 0 // so that it animated from default offset 300 to 0 appearing to fly in 
            }
    }
}

// MARK - :Location Buttons
struct ShareLocationButton: View {
    
    
    @ObservedObject var locViewModel: LocationViewModel
    @Binding var isLoadingLocation: Bool
    @Binding var showLocationUnavailableSheet: Bool
    @Binding var isServiceDisabled: Bool
    @State private var userLatitude: Double?
    @State private var userLongitude: Double?
    @State private var locationData: UserLocationModel? // To store fetched location data
    @State private var isLocationLoaded: Bool = false
    @Binding var isUserLocationLoaded: Bool

    var body: some View {
        VStack {
            Button(action: {
                locViewModel.requestLocation() // Request the current location
            }) {
                if isLoadingLocation {
                    LoadingButtonView()
                } else if showLocationUnavailableSheet || isServiceDisabled {
                    UnavailableButtonView()
                } else if isLocationLoaded {
                    LocationLoadedButtonView(locationData: locationData)
                } else {
                    ShareLocationDefaultButtonView()
                }
            }
            .padding(.horizontal, 20)
            .disabled(showLocationUnavailableSheet || isLoadingLocation || isLocationLoaded || isServiceDisabled || isUserLocationLoaded)
        }
        .onReceive(locViewModel.$UserLatitude) { newLatitude in
            userLatitude = newLatitude
            isLoadingLocation = true
            fetchLocationIfPossible()
        }
        .onReceive(locViewModel.$UserLongitude) { newLongitude in
            userLongitude = newLongitude
            isLoadingLocation = false
            fetchLocationIfPossible()
        }
    }
    
    // Function to fetch location data when latitude and longitude are both available
    private func fetchLocationIfPossible() {
        guard let latitude = userLatitude, let longitude = userLongitude else { return }
        locViewModel.fetchLocationData(latitude: latitude, longitude: longitude) { location, error in
            if let location = location {
                locationData = location
                isLoadingLocation = false
                isLocationLoaded = true
                isUserLocationLoaded = true

                
            } else if let error = error {
                print("Error fetching location: \(error.localizedDescription)")
                isLoadingLocation = false
                showLocationUnavailableSheet = true
                isServiceDisabled = true
            }
        }
    }
}

struct LoadingButtonView: View {
    var body: some View {
        ZStack {
            Text(" ")
                .font(Font.custom("LexendDeca-SemiBold", size: 18))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 65)
                .background(Color("SecondaryColor"))
                .cornerRadius(15)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
        }
    }
}

struct UnavailableButtonView: View {
    var body: some View {
        Text("Service unavailable")
            .font(Font.custom("LexendDeca-SemiBold", size: 18))
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 65)
            .background(Color.gray)
            .cornerRadius(15)
    }
}

struct LocationLoadedButtonView: View {
    let locationData: UserLocationModel?
    
    var body: some View {
        Text("\(locationData?.localityName ?? ""), \(locationData?.name ?? "")")
            .font(Font.custom("LexendDeca-SemiBold", size: 18))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 65)
            .background(Color("SecondaryColor"))
            .cornerRadius(15)
    }
}

struct ShareLocationDefaultButtonView: View {
    var body: some View {
        Text("Share Current Location")
            .font(Font.custom("LexendDeca-SemiBold", size: 18))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 65)
            .background(Color("SecondaryColor"))
            .cornerRadius(15)
    }
}

struct GradientBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color("PrimaryColor"), Color.pink.opacity(0.4)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK - :Postcode Field
struct PostcodeTextField: View {
    @ObservedObject var locViewModel: LocationViewModel
    @Binding var userPostcode: String
    @Binding var isLoadingPostcode: Bool
    @State private var locationData: UserLocationModel?
    @Binding var showLocationUnavailableSheet: Bool
    @State private var isPostcodeLoaded: Bool = false
    @State private var wobbleEffect: CGFloat = 0.0
    @Binding var isUserLocationLoaded: Bool

    var body: some View {
        VStack {
            if isLoadingPostcode {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                    .scaleEffect(1.5)
                    .padding()
            } else if isPostcodeLoaded, let locationData = locationData {
                Text("\(locationData.localityName), \(locationData.name)")
                    .font(Font.custom("LexendDeca-SemiBold", size: 18))
                    .foregroundColor(.green)
                    .padding()
                    .frame(height: 50) // Matches the height of the TextField
                    .frame(maxWidth: .infinity) // Matches the width of the TextField
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .rotationEffect(.degrees(wobbleEffect))
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 0.1)
                                .repeatCount(6, autoreverses: true)
                        ) {
                            wobbleEffect = 6 // Slight wobble
                        }
                        
                        // Return to original orientation after wobbling
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // 0.6 seconds after postcode is retrieved
                            withAnimation {
                                wobbleEffect = 0
                            }
                        }
                    }
            } else {
                TextField("Enter UK Postcode 🔎", text: $userPostcode)
                    .font(Font.custom("LexendDeca-SemiBold", size: 18))
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 50) // Set consistent height
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .submitLabel(.route)
                    .onSubmit {
                        isLoadingPostcode = true
                        fetchLocationIfPossible()
                    }
                    .disabled(isPostcodeLoaded || isUserLocationLoaded)
            }
        }
    }

    private func fetchLocationIfPossible() {
        let postcode = userPostcode
        locViewModel.fetchLocationData(postcode: postcode) { location, error in
            if let location = location {
                locationData = location
                isLoadingPostcode = false
                isPostcodeLoaded = true
                isUserLocationLoaded = true
            } else if let error = error {
                print("Error fetching location: \(error.localizedDescription)")
                isLoadingPostcode = false
                showLocationUnavailableSheet = true
            }
        }
    }
}

#Preview {

    SupplyLocationView()
    
}


