import SwiftUI

struct FoodView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "fork.knife")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 40))
                    .padding()
                
                // 这里可以添加食物相关的列表或其他内容
                List {
                    NavigationLink(destination: Text("Meal Plans")) {
                        Label("Meal Plans", systemImage: "text.book.closed")
                    }
                    NavigationLink(destination: Text("Nutrition Tracking")) {
                        Label("Nutrition Tracking", systemImage: "chart.pie")
                    }
                    NavigationLink(destination: Text("Recipe Collection")) {
                        Label("Recipe Collection", systemImage: "star")
                    }
                }
            }
            .navigationTitle("Food")
        }
    }
} 