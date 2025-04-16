// import SwiftUI

// struct GymView: View {
//     @Environment(\.managedObjectContext) private var context
//     @StateObject private var timerManager = TrainingTimerManager() // 创建计时管理器实例

//     var body: some View {
//         NavigationStack {
//             VStack {
//                 Image(systemName: "dumbbell.fill")
//                     .imageScale(.large)
//                     .foregroundStyle(.tint)
//                     .font(.system(size: 40))
//                     .padding()
                
//                 Text("Welcome to Gym")
//                     .font(.title)
                
//                 List {
//                     NavigationLink(destination: TrainingPlanView()) {
//                         Label("Training Plan", systemImage: "square.and.pencil")
//                     }
                    
//                     NavigationLink(destination: RecordPlanView(context: context)
//                         .environmentObject(timerManager)) { // 注入计时管理器
//                         Label("Training Record", systemImage: "timer")
//                     }
                    
//                     NavigationLink(destination: Text("训练数据 (Training Data)")) {
//                         Label("Training Data", systemImage: "chart.bar.fill")
//                     }
//                 }
//             }
//             .navigationTitle("Gym")
//         }
//     }
// }

import SwiftUI

struct GymView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var timerManager = TrainingTimerManager()
    
    @State private var showConfirmation = false
    @State private var navigateToRecord = false
    @State private var navigateToPlan = false
    @State private var navigateToData = false

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "dumbbell.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 40))
                    .padding(.top, 40)
                Text("")
                    .font(.title)
                    .padding(.bottom, 20)

                List {
                    buttonRow(label: "训练计划", systemImage: "square.and.pencil") {
                        navigateToPlan = true
                    }

                    buttonRow(label: "训练计时", systemImage: "timer") {
                        showConfirmation = true
                    }

                    buttonRow(label: "训练数据", systemImage: "chart.bar.fill") {
                        navigateToData = true
                    }
                }

                // Hidden navigation triggers
                NavigationLink("", destination: TrainingPlanView(), isActive: $navigateToPlan)
                    .hidden()
                NavigationLink("", destination: RecordPlanView(context: context).environmentObject(timerManager), isActive: $navigateToRecord)
                    .hidden()
                NavigationLink("", destination: Text("训练数据 (Training Data)"), isActive: $navigateToData)
                    .hidden()
            }
            .navigationTitle("Training")
            .alert("是否开始训练计时", isPresented: $showConfirmation) {
                Button("确认", role: .destructive) {
                    navigateToRecord = true
                }
                Button("取消", role: .cancel) {}
            }
        }
    }
    
    // 统一样式按钮
    @ViewBuilder
    private func buttonRow(label: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .frame(width: 24) // 添加固定宽度
                    .offset(x: -2) // 微调位置
                
                Text(label)
                    .font(.title2)
                    .foregroundColor(.black)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
    }
}