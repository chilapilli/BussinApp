//
//  SearchBusesHomePageViewModel.swift
//  Bussin
//
//  Created by Matthew Tsang on 31/08/2024.
//
import Foundation
import Combine

class BusRoutesViewModel: ObservableObject {
    @Published var busRoutes: [BusRoute] = []
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let atcoAreaCode: String
    
    init(atcoAreaCode: String) {
        self.atcoAreaCode = atcoAreaCode
        fetchBusRoutes()
    }
    
    func fetchBusRoutes() {
        guard let url = URL(string: "http://localhost:5000/routes?atco_code=\(atcoAreaCode)") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [String: OperatorInfo].self, decoder: JSONDecoder())
            .map { dict in
                dict.map { lineId, operatorInfo in
                    BusRoute(lineId: lineId, operatorName: operatorInfo.operatorName, operatorNoc: operatorInfo.operatorNoc)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching bus routes: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] routes in
                self?.busRoutes = routes
            })
            .store(in: &cancellables)
    }
    
    var filteredRoutes: [BusRoute] {
        print("Bus routes successfully retrieved")
        if searchText.isEmpty {
            return []
        } else {
            return busRoutes.filter { $0.lineId.lowercased().hasPrefix(searchText.lowercased()) }
        }
    }
}

struct OperatorInfo: Codable {
    let operatorName: String
    let operatorNoc: String

    enum CodingKeys: String, CodingKey {
        case operatorName = "operator_name"
        case operatorNoc = "operator_noc"
    }
}
