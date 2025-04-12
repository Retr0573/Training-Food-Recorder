//
//  ContentView.swift
//  HelloIOS
//
//  Created by 吴圣琪 on 2025/4/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GymView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Gym")
                }
            
            FoodView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Food")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("My")
                }
        }
    }
}

#Preview {
    ContentView()
}

