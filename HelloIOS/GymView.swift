import SwiftUI

struct GymView: View {
    @Environment(\.managedObjectContext) private var context

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
                
                List {
                    NavigationLink(destination: TrainingPlanView()) {
                        Label("Training Plan", systemImage: "square.and.pencil")
                    }
                    
                    NavigationLink(destination: RecordPlanView(context: context)) {
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