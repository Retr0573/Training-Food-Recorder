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
                HeaderIcon(systemName: "dumbbell.fill") // 使用通用组件

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
                    .font(.title3)
                    .foregroundStyle(.tint)
                    .frame(width: 24, height: 24) // 添加固定宽高
                
                Text(label)
                    .font(.callout)
                    .foregroundColor(.black)
            }
            .padding(.vertical, 5)
            .contentShape(Rectangle())
        }
    }
}

// 通用的 HeaderIcon 组件
struct HeaderIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .imageScale(.large)
            .foregroundStyle(.tint)
            .font(.system(size: 40))
            .frame(width: 60, height: 60) // 设置固定宽高
            .padding()
    }
}

