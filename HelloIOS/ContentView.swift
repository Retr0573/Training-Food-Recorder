//
//  ContentView.swift
//  HelloIOS
//
//  Created by 吴圣琪 on 2025/4/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "dumbbell")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello sir")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

