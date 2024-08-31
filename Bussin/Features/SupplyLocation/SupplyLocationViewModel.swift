import SwiftUI
import CoreLocation

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    
    @Published var UserLatitude: Double?
    @Published var UserLongitude: Double?
    @Published var AtcoAreaCode: String?
    @Published var UserLocation: String?
    @AppStorage("AtcoAreaCode") var storedAtcoAreaCode: String = ""
    @AppStorage("UserLatitude") var storedLatitude: Double = 0.0
    @AppStorage("UserLongitude") var storedLongitude: Double = 0.0
    @AppStorage("UserRegion") var storedRegion: String = ""
    @AppStorage("UserPostcode") var storedPostcode: String = ""
    
    private var locationManager: CLLocationManager?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationPermissionDenied: Bool = false


    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }
    
    func requestLocation() {
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location.coordinate
            locationManager?.stopUpdatingLocation()
            print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            UserLatitude = location.coordinate.latitude
            UserLongitude = location.coordinate.longitude
            storedLongitude = location.coordinate.longitude
            storedLatitude = location.coordinate.latitude
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            locationPermissionDenied = true
        default:
            locationPermissionDenied = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let cleError = error as? CLError, cleError.code == .denied {
            locationPermissionDenied = true
        }
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
    func fetchLocationData(postcode: String? = nil, latitude: Double? = nil, longitude: Double? = nil, completion: @escaping (UserLocationModel?, Error?) -> Void) {
        
        print("fetch location is called")
        
        let urlString = postcode != nil ? "http://localhost:5000/location?postcode=\(postcode!)" : "http://localhost:5000/location?latitude=\(latitude!)&longitude=\(longitude!)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."]))
            return
        }
        
        print(url)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Check for networking error
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            // Check the HTTP response status
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("HTTP error: Status code \(httpResponse.statusCode)")
                let httpError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error: Status code \(httpResponse.statusCode)"])
                completion(nil, httpError)
                return
            }
            
            // Check if data exists
            guard let data = data else {
                print("No data received from server.")
                let noDataError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server."])
                completion(nil, noDataError)
                return
            }
            
            // Attempt to decode data
            do {
                let decoder = JSONDecoder()
                print(String(data: data, encoding: .utf8) ?? "An Error has occured.")
                let locationData = try decoder.decode(UserLocationModel.self, from: data)
                // Call completion on the main thread
                DispatchQueue.main.async {
                    completion(locationData, nil)
                    self.storedLatitude = locationData.latitude
                    self.storedLongitude = locationData.longitude
                    self.storedAtcoAreaCode = String(locationData.atcoAreaCode)
                    self.storedRegion = locationData.name
                    self.storedPostcode = locationData.postcode
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}
