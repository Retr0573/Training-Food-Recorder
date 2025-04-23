import SwiftUI
import CoreData
import UserNotifications

struct RecordItemView: View {
    // MARK: - 属性
    // 视图模型
    @StateObject private var viewModel: RecordItemViewModel
    // 全局计时器管理器
    @EnvironmentObject var timerManager: TrainingTimerManager
    // 视图呈现环境
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - 状态变量
    // 弹窗控制
    @State private var showExitConfirmation = false  // 控制退出确认弹窗
    @State private var showTrainingEndedAlert = false // 控制训练结束弹窗
    @State private var trainingDuration: String = ""  // 存储训练持续时间
    @State private var showRestEndedAlert = false     // 控制休息结束弹窗
    @State private var nextSetName: String = ""       // 下一组训练信息
    
    // 计时器相关
    @State private var trainingTimer: DispatchSourceTimer?   // 训练计时器
    @State private var restingTimer: DispatchSourceTimer?    // 休息计时器
    @State private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid // 后台任务ID
    
    // 时间跟踪
    @State private var trainingStartTime: Date?     // 训练开始时间
    @State private var restingStartTime: Date?      // 休息开始时间
    @State private var currentTrainingSet: SetState? // 当前训练的组
    @State private var currentRestingSet: SetState?  // 当前休息的组

    // MARK: - 初始化
    init(context: NSManagedObjectContext, item: T_Item) {
        _viewModel = StateObject(wrappedValue: RecordItemViewModel(context: context, item: item))
    }

    // MARK: - 视图主体
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
                requestNotificationPermission()
                UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
                if !timerManager.isProjectTraining {
                    timerManager.startProjectTraining()
                }
                setupNotificationObservers()
            }
            .onDisappear {
                removeNotificationObservers()
                invalidateTimers()
            }

            VStack {
                Spacer()
                HStack(spacing: 12) {
                    TrainingRecordButton()
                        .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    Button(action: {
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
                            Text(timerManager.projectElapsedTimeString())
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
        .alert("确认结束项目训练？", isPresented: $showExitConfirmation) {
            Button("结束训练", role: .destructive) {
                trainingDuration = timerManager.projectElapsedTimeString()
                timerManager.endProjectTraining()
                showTrainingEndedAlert = true
            }
            Button("取消", role: .cancel) {}
        }
        .alert("项目训练已结束", isPresented: $showTrainingEndedAlert) {
            Button("确定") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("训练用时：\(trainingDuration)")
        }
        .alert("休息结束", isPresented: $showRestEndedAlert) {
            Button("去开始下一组") {
                showRestEndedAlert = false
            }
        } message: {
            Text(nextSetName)
        }
    }

    // MARK: - 返回按钮
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

    // MARK: - 通知观察器设置
    /// 设置应用状态变化的通知观察器
    private func setupNotificationObservers() {
        // 监听应用进入后台通知
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [self] _ in
            handleAppEnteredBackground()
        }

        // 监听应用进入前台通知
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [self] _ in
            handleAppEnteredForeground()
        }
    }

    /// 移除通知观察器
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    // MARK: - 应用状态处理
    /// 处理应用进入后台
    private func handleAppEnteredBackground() {
        print("应用进入后台")
        // 开始后台任务以获取额外执行时间
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [self] in
            self.endBackgroundTask()
        }

        // 保存训练开始时间
        if currentTrainingSet?.isTraining == true {
            trainingStartTime = Date().addingTimeInterval(-TimeInterval(currentTrainingSet?.elapsedTime ?? 0))
        }

        // 保存休息开始时间
        if currentRestingSet?.isResting == true {
            let totalRestTime = TimeInterval(currentRestingSet?.set.restTime ?? 0)
            let remainingTime = TimeInterval(currentRestingSet?.remainingRestTime ?? 0)
            restingStartTime = Date().addingTimeInterval(remainingTime - totalRestTime)
        }
    }

    /// 处理应用进入前台
    private func handleAppEnteredForeground() {
        print("应用进入前台")

        // 更新训练时间
        if let startTime = trainingStartTime, let set = currentTrainingSet, set.isTraining {
            let elapsedSeconds = Int(Date().timeIntervalSince(startTime))
            set.elapsedTime = elapsedSeconds
            print("更新训练时间：\(elapsedSeconds)秒")
        }

        // 更新休息时间
        if let startTime = restingStartTime, let set = currentRestingSet, set.isResting {
            let totalRestTime = Int(set.set.restTime)
            let elapsedSeconds = Int(Date().timeIntervalSince(startTime))
            let remainingTime = max(0, totalRestTime - elapsedSeconds)

            set.remainingRestTime = remainingTime
            print("更新休息时间：剩余\(remainingTime)秒")

            // 如果休息已经结束，触发休息结束回调
            if remainingTime <= 0 && set.isResting {
                set.isResting = false
                set.onRestingEnded?()
                currentRestingSet = nil
                restingStartTime = nil
            }
        }

        // 结束后台任务
        endBackgroundTask()
    }

    /// 结束后台任务
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }

    /// 清理计时器
    private func invalidateTimers() {
        trainingTimer?.cancel()
        trainingTimer = nil
        restingTimer?.cancel()
        restingTimer = nil
    }

    // MARK: - 训练控制
    /// 开始或结束训练
    /// - Parameter setState: 要开始训练的组
    private func startTraining(for setState: SetState) {
        // 确保按顺序训练组
        guard let firstUntrainedSet = viewModel.sets.first(where: { !$0.isTrained }) else { return }
        guard firstUntrainedSet.id == setState.id else { return }

        if !setState.isTraining {
            // 开始训练逻辑
            setState.isTraining = true
            setState.elapsedTime = 0

            // 保存当前训练组
            currentTrainingSet = setState
            trainingStartTime = Date()

            // 创建训练计时器
            let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
            timer.schedule(deadline: .now(), repeating: 1.0)
            timer.setEventHandler { [weak setState] in
                guard let set = setState else { return }
                if set.isTraining {
                    set.elapsedTime += 1
                }
            }
            timer.resume()
            trainingTimer = timer

            // 通知其他组检查休息状态
            for otherSet in viewModel.sets where otherSet.id != setState.id {
                otherSet.checkRestingStatus(isAnySetTraining: true)
            }
        } else {
            // 结束训练逻辑
            setState.isTraining = false
            setState.isTrained = true
            setState.trainingDuration = Int(setState.elapsedTime)

            // 清理训练相关状态
            trainingTimer?.cancel()
            trainingTimer = nil
            currentTrainingSet = nil
            trainingStartTime = nil

            // 将组标记为已训练
            viewModel.markSetAsTrained(setState)

            // 开始休息计时
            setState.isResting = true
            setState.remainingRestTime = Int(setState.set.restTime)

            // 保存当前休息组
            currentRestingSet = setState
            restingStartTime = Date().addingTimeInterval(-TimeInterval(Int(setState.set.restTime) - setState.remainingRestTime))

            // 设置休息结束回调
            setState.onRestingEnded = {
                if let nextSet = viewModel.sets.first(where: { !$0.isTrained }) {
                    nextSetName = "下一组：重量 \(nextSet.set.weight) kg，次数 \(nextSet.set.reps)"
                } else {
                    nextSetName = "所有训练已完成！"
                }
                sendRestEndedNotification()
            }

            // 创建休息计时器
            let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
            timer.schedule(deadline: .now(), repeating: 1.0)
            timer.setEventHandler { [weak setState] in
                guard let set = setState else { return }
                if set.remainingRestTime > 0 {
                    set.remainingRestTime -= 1
                } else {
                    set.isResting = false
                    // 清理休息相关状态
                    if set === currentRestingSet {
                        currentRestingSet = nil
                        restingStartTime = nil
                    }
                    set.onRestingEnded?() // 触发休息结束回调
                    // 停止计时器
                    DispatchQueue.main.async {
                        restingTimer?.cancel()
                        restingTimer = nil
                    }
                }
            }
            timer.resume()
            restingTimer = timer
        }
    }

    // MARK: - 通知处理
    /// 请求通知权限
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

    /// 发送休息结束通知
    private func sendRestEndedNotification() {
        print("发送休息结束通知")
        let content = UNMutableNotificationContent()
        content.title = "休息结束"
        content.body = nextSetName
        content.sound = .default
        print("通知内容: \(content.title), \(content.body)")

        // 设置触发器为立即触发
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // 创建通知请求
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // 添加通知请求
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送通知失败: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - 组卡片视图
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
        .background(backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    // MARK: - 背景色视图
    /// 动态背景颜色，用于显示休息进度
    private var backgroundColor: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 底层背景色
                Color.green.opacity(0.15)

                if setState.isResting {
                    // 动态进度条背景，显示休息进度
                    Color.green
                        .frame(width: geometry.size.width * progress)
                        .animation(.linear(duration: 1.0), value: progress)
                } else {
                    // 固定背景色
                    fixedBackgroundColor
                }
            }
            .cornerRadius(10)
        }
    }

    /// 固定背景色，基于组的当前状态
    private var fixedBackgroundColor: Color {
        if setState.isTrained {
            return Color.green    // 已完成训练
        } else if setState.isTraining {
            return Color.blue     // 正在训练
        } else if isStartable {
            return Color.yellow   // 可以开始训练
        } else {
            return Color.gray     // 不可开始训练
        }
    }

    /// 计算休息进度比例
    private var progress: CGFloat {
        guard setState.isResting else { return 0 }
        let totalRestTime = CGFloat(setState.set.restTime)
        let remainingTime = CGFloat(setState.remainingRestTime)
        return max(0, min(1, 1 - remainingTime / totalRestTime))
    }
}
