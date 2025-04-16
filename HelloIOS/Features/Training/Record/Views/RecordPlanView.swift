import SwiftUI
import CoreData
struct RecordPlanView: View {
    @StateObject private var viewModel: RecordPlanViewModel
    @EnvironmentObject var timerManager: TrainingTimerManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showExitConfirmation = false
    @State private var showTrainingEndedAlert = false
    @State private var trainingDuration: String = ""

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: RecordPlanViewModel(context: context))
    }

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.themes, id: \.id) { theme in
                            NavigationLink(destination: RecordThemeView(context: viewModel.managedObjectContext, theme: theme)
                                .environmentObject(timerManager)) {
                                CardView(theme: theme)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("训练计划")
            .navigationBarBackButtonHidden(true) // 隐藏系统返回按钮
            .onAppear {
                // 自动开始整体训练
                if !timerManager.isTraining {
                    timerManager.startTraining()
                }
            }

            // 固定在底部的按钮
            VStack {
                Spacer()
                HStack(spacing: 12) { // 调整按钮之间的间距
                    // 显示训练计时
                    TrainingRecordButton()
                        .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30) // 设置最小高度
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    // 结束训练按钮
                    Button(action: {
                        if timerManager.isTraining {
                            showExitConfirmation = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "stop.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("结束训练")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30) // 设置最小高度
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
        // 确认是否结束整体训练
        .alert("确认结束训练？", isPresented: $showExitConfirmation) {
            Button("结束训练", role: .destructive) {
                trainingDuration = timerManager.elapsedTimeString()
                timerManager.endTraining()
                showTrainingEndedAlert = true // 显示训练结束提示
            }
            Button("取消", role: .cancel) {}
        }
        // 提示训练已结束
        .alert("训练已结束", isPresented: $showTrainingEndedAlert) {
            Button("确定") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("训练用时：\(trainingDuration)")
        }
    }

}
struct CardView: View {
    let theme: T_Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(theme.name ?? "未命名主题")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let note = theme.note, !note.isEmpty {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
