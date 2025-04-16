import SwiftUI
import CoreData
import UserNotifications
struct RecordItemView: View {
    @StateObject private var viewModel: RecordItemViewModel
    @EnvironmentObject var timerManager: TrainingTimerManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showExitConfirmation = false
    @State private var showTrainingEndedAlert = false
    @State private var trainingDuration: String = ""
    @State private var showRestEndedAlert = false // 控制休息结束后的弹窗显示
    @State private var nextSetName: String = ""   // 保存下一组的名称


    init(context: NSManagedObjectContext, item: T_Item) {
        _viewModel = StateObject(wrappedValue: RecordItemViewModel(context: context, item: item))
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.sets) { setState in
                        SetCardView(
                            setState: setState,
                            onTrain: { selectedSet in
                                startTraining(for: selectedSet)
                            },
                            isStartable: viewModel.isSetStartable(setState)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.currentItem.name ?? "未命名项目")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
            .onAppear {
                requestNotificationPermission() // 请求通知权限
                UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
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
        .alert("休息结束", isPresented: $showRestEndedAlert) {
            Button("去开始下一组") {
                // 用户点击后可以触发下一组训练逻辑
                showRestEndedAlert = false  
            }
        } message: {
            Text(nextSetName)
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

    private func startTraining(for setState: SetState) {
        guard let firstUntrainedSet = viewModel.sets.first(where: { !$0.isTrained }) else { return }
        guard firstUntrainedSet.id == setState.id else { return } // 确保按顺序训练

        if !setState.isTraining {
            // 开始训练
            setState.isTraining = true
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if setState.isTraining {
                    setState.elapsedTime += 1
                } else {
                    timer.invalidate()
                }
            }
            // 通知其他组检查休息状态
            for otherSet in viewModel.sets where otherSet.id != setState.id {
                otherSet.checkRestingStatus(isAnySetTraining: true)
            }
        } else {
            // 停止训练并标记为已训练
            setState.isTraining = false
            setState.isTrained = true
            setState.trainingDuration = setState.elapsedTime // 保存训练时长
            viewModel.markSetAsTrained(setState)

            // 开始休息倒计时
            setState.isResting = true
            // 实现回调
            setState.onRestingEnded = { 
                // 回调逻辑：休息结束时触发
                if let nextSet = viewModel.sets.first(where: { !$0.isTrained }) {
                    nextSetName = "下一组：重量 \(nextSet.set.weight) kg，次数 \(nextSet.set.reps)"
                } else {
                    nextSetName = "所有训练已完成！"
                }
                // showRestEndedAlert = true
                // 发送本地通知
                sendRestEndedNotification()
            }
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if setState.remainingRestTime > 0 {
                    setState.remainingRestTime -= 1
                } else {
                    setState.isResting = false
                    setState.onRestingEnded?() // 触发休息结束回调
                    timer.invalidate()
                }
            }
        }
    }
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知授权失败: \(error.localizedDescription)")
            } else if granted {
                print("通知授权成功")
            } else {
                print("用户拒绝通知授权")
            }
        }
    }
    private func sendRestEndedNotification() {
        print("发送休息结束通知")
        let content = UNMutableNotificationContent()
        content.title = "休息结束"
        content.body = nextSetName
        content.sound = .default
        print("通知内容: \(content.title), \(content.body)")
        // 设置触发时间为立即
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 创建通知请求
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // 添加通知请求到通知中心
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送通知失败: \(error.localizedDescription)")
            }
        }
    }
}
struct SetCardView: View {
    @ObservedObject var setState: SetState
    let onTrain: (SetState) -> Void
    let isStartable: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("重量: \(setState.set.weight, specifier: "%.1f") kg")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("次数: \(setState.set.reps)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("休息时间: \(setState.set.restTime) 秒")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if setState.set.isWarmup {
                        Text("热身组")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                if setState.isTraining {
                    Button(action: {
                        onTrain(setState)
                    }) {
                        Text("结束训练")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    Text("计时中: \(setState.elapsedTime) 秒")
                        .font(.caption)
                        .foregroundColor(.white)
                } else if setState.isResting {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("休息中")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("剩余时间: \(setState.remainingRestTime) 秒")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if setState.isTrained {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("已完成")
                            .font(.caption)
                            .foregroundColor(.primary)
                        if let duration = setState.trainingDuration {
                            Text("训练时长: \(duration) 秒")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else if isStartable {
                    Button(action: {
                        onTrain(setState)
                    }) {
                        Text("开始训练")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor) // 使用动态背景
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    // private var backgroundColor: Color {
    //     if setState.isResting {
    //         return Color.green.opacity(0.3) // 浅绿色
    //     } else if setState.isTrained {
    //         return Color.green // 已完成训练的颜色
    //     } else if setState.isTraining {
    //         return Color.blue // 正在训练的颜色
    //     } else if isStartable {
    //         return Color.yellow // 可开始训练的颜色
    //     } else {
    //         return Color.gray // 默认颜色
    //     }
    // }
    private var backgroundColor: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 浅绿色背景
                Color.green.opacity(0.15)
                
                if setState.isResting {
                    // 动态绿色覆盖
                    Color.green
                        .frame(width: geometry.size.width * progress)
                        .animation(.linear(duration: 1.0), value: progress) // 动画效果
                }
                else{
                    fixedBackgroundColor
                }
            }
            .cornerRadius(10) // 保持圆角
        }
    }
    private var fixedBackgroundColor: Color {
        if setState.isTrained {
            return Color.green // 已完成训练的颜色
        } else if setState.isTraining {
            return Color.blue // 正在训练的颜色
        } else if isStartable {
            return Color.yellow // 可开始训练的颜色
        } else {
            return Color.gray // 默认颜色
        }
    }
    private var progress: CGFloat {
        guard setState.isResting else { return 0 }
        let totalRestTime = CGFloat(setState.set.restTime)
        let remainingTime = CGFloat(setState.remainingRestTime)
        return max(0, min(1, 1 - remainingTime / totalRestTime)) // 计算进度比例
    }
}
// struct SetCardView: View {
//     @ObservedObject var setState: SetState
//     let onTrain: (SetState) -> Void
//     let isStartable: Bool

//     var body: some View {
//         VStack(alignment: .leading, spacing: 8) {
//             HStack {
//                 VStack(alignment: .leading, spacing: 4) {
//                     Text("重量: \(setState.set.weight, specifier: "%.1f") kg")
//                         .font(.headline)
//                         .foregroundColor(.primary)
                    
//                     Text("次数: \(setState.set.reps)")
//                         .font(.subheadline)
//                         .foregroundColor(.secondary)
                    
//                     Text("休息时间: \(setState.set.restTime) 秒")
//                         .font(.subheadline)
//                         .foregroundColor(.secondary)
                    
//                     if setState.set.isWarmup {
//                         Text("热身组")
//                             .font(.caption)
//                             .foregroundColor(.orange)
//                     }
//                 }
                
//                 Spacer()
                
//                 if setState.isTraining {
//                     Button(action: {
//                         onTrain(setState)
//                     }) {
//                         Text("结束训练")
//                             .font(.caption)
//                             .foregroundColor(.white)
//                             .padding()
//                             .background(Color.red)
//                             .cornerRadius(8)
//                     }
//                     Text("计时中: \(setState.elapsedTime) 秒")
//                         .font(.caption)
//                         .foregroundColor(.white)
//                 } else if setState.isResting {
//                     VStack(alignment: .leading, spacing: 4) {
//                         Text("休息中")
//                             .font(.caption)
//                             .foregroundColor(.red)
//                         Text("剩余时间: \(setState.remainingRestTime) 秒")
//                             .font(.caption)
//                             .foregroundColor(.secondary)
//                     }
//                 } else if setState.isTrained {
//                     VStack(alignment: .leading, spacing: 4) {
//                         Text("已完成")
//                             .font(.caption)
//                             .foregroundColor(.primary)
//                         if let duration = setState.trainingDuration {
//                             Text("训练时长: \(duration) 秒")
//                                 .font(.caption)
//                                 .foregroundColor(.secondary)
//                         }
//                     }
//                 } else if isStartable {
//                     Button(action: {
//                         onTrain(setState)
//                     }) {
//                         Text("开始训练")
//                             .font(.caption)
//                             .foregroundColor(.white)
//                             .padding()
//                             .background(Color.blue)
//                             .cornerRadius(8)
//                     }
//                 }
//             }
//         }
//         .padding()
//         .frame(maxWidth: .infinity, alignment: .leading)
//         .background(backgroundColor)
//         .cornerRadius(10)
//         .shadow(radius: 2)
//     }

//     private var backgroundColor: Color {
//         if setState.isResting {
//             return Color.green.opacity(0.3) // 浅绿色
//         } else if setState.isTrained {
//             return Color.green // 已完成训练的颜色
//         } else if setState.isTraining {
//             return Color.blue // 正在训练的颜色
//         } else if isStartable {
//             return Color.yellow // 可开始训练的颜色
//         } else {
//             return Color.gray // 默认颜色
//         }
//     }
// }