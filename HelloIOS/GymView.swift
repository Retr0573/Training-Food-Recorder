import SwiftUI

struct GymView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var timerManager = TrainingTimerManager() // 创建计时管理器实例

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "dumbbell.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 40))
                    .padding()
                
                Text("Welcome to Gym")
                    .font(.title)
                
                List {
                    NavigationLink(destination: TrainingPlanView()) {
                        Label("Training Plan", systemImage: "square.and.pencil")
                    }
                    
                    NavigationLink(destination: RecordPlanView(context: context)
                        .environmentObject(timerManager)) { // 注入计时管理器
                        Label("Training Record", systemImage: "timer")
                    }
                    
                    NavigationLink(destination: Text("训练数据 (Training Data)")) {
                        Label("Training Data", systemImage: "chart.bar.fill")
                    }
                }
            }
            .navigationTitle("Gym")
        }
    }
}