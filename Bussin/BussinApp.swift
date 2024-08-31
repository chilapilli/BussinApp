//
//  BussinApp.swift
//  Bussin
//
//  Created by Matthew Tsang on 29/08/2024.
//

import SwiftUI
import Combine


@main
struct BussinApp: App {
    
    @AppStorage("IsUserLocationLoaded") var userLocationLoaded: Bool = false 
    
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                
                if !userLocationLoaded{
                    SupplyLocationView()
                } else {
                    SearchBusLocationHomepageView()
                    
                }
            }
        }
    }
}
