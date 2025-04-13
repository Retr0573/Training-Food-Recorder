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
                
                // 修改列表内容以匹配设计文档的三个主要部分
                List {
                    NavigationLink(destination: TrainingPlanView()) {
                        Label("训练计划(Training Plan)", systemImage: "square.and.pencil")
                    }
                    
                    NavigationLink(destination: Text("训练计时 (Training Record)")) {
                        Label("训练计时(Training Record)", systemImage: "timer")
                    }
                    
                    NavigationLink(destination: Text("训练数据 (Training Data)")) {
                        Label("训练数据(Training Data)", systemImage: "chart.bar.fill")
                    }
                }
            }
            .navigationTitle("Gym")
        }
    }
} 
