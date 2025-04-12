import SwiftUI

struct GymView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "dumbbell.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 40))
                    .padding()
                
                Text("Welcome to Gym")
                    .font(.title)
                
                // 这里可以添加健身相关的列表或其他内容
                List {
                    NavigationLink(destination: Text("Workout Plans")) {
                        Label("Workout Plans", systemImage: "list.bullet")
                    }
                    NavigationLink(destination: Text("Exercise Records")) {
                        Label("Exercise Records", systemImage: "chart.bar")
                    }
                    NavigationLink(destination: Text("Training Schedule")) {
                        Label("Training Schedule", systemImage: "calendar")
                    }
                }
            }
            .navigationTitle("Gym")
        }
    }
} 