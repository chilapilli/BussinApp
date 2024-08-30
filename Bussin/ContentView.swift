//
//  ContentView.swift
//  Bussin
//
//  Created by Matthew Tsang on 29/08/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            
            Color("PrimaryColor")
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                Text("Initial Commit!!")
                    .font(Font.custom("LexendDeca-SemiBold", size: 20))
                
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
