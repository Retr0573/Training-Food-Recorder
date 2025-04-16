import SwiftUI
import CoreData

struct RecordItemView: View {
    @StateObject private var viewModel: RecordItemViewModel
    @EnvironmentObject var timerManager: TrainingTimerManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showExitConfirmation = false
    @State private var showTrainingEndedAlert = false
    @State private var trainingDuration: String = ""

    init(context: NSManagedObjectContext, item: T_Item) {
        _viewModel = StateObject(wrappedValue: RecordItemViewModel(context: context, item: item))
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.sets, id: \.id) { set in
                        SetCardView(set: set)
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.currentItem.name ?? "未命名项目")
            .navigationBarBackButtonHidden(true) // 隐藏系统返回按钮
            .navigationBarItems(leading: backButton) // 添加自定义返回按钮
            .onAppear {
                // 自动开始项目训练
                if !timerManager.isProjectTraining {
                    timerManager.startProjectTraining()
                }
            }

            // 固定在底部的按钮
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    // 整体训练计时按钮
                    TrainingRecordButton()
                        .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30) 
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    // 项目训练计时按钮
                    Button(action: {
                        // 询问是否结束项目训练
                        if timerManager.isProjectTraining {
                            showExitConfirmation = true
                        }
                    }) {
                        VStack {
                            
                            HStack {
                                Image(systemName: "stop.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("结束项目训练")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Text(timerManager.projectElapsedTimeString()) // 显示项目训练计时
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
        // 确认是否结束项目训练
        .alert("确认结束项目训练？", isPresented: $showExitConfirmation) {
            Button("结束训练", role: .destructive) {
                trainingDuration = timerManager.projectElapsedTimeString()
                timerManager.endProjectTraining()
                showTrainingEndedAlert = true // 显示训练结束提示
            }
            Button("取消", role: .cancel) {}
        }
        // 提示训练已结束
        .alert("项目训练已结束", isPresented: $showTrainingEndedAlert) {
            Button("确定") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("训练用时：\(trainingDuration)")
        }
    }

    // 自定义返回按钮
    private var backButton: some View {
        Button(action: {
            if timerManager.isProjectTraining {
                showExitConfirmation = true
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("返回")
            }
        }
    }
}

struct SetCardView: View {
    let set: T_Set

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("重量: \(set.weight, specifier: "%.1f") kg")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("次数: \(set.reps)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("休息时间: \(set.restTime) 秒")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if set.isWarmup {
                Text("热身组")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
