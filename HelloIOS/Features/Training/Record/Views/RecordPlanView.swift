import SwiftUI
import CoreData

struct RecordPlanView: View {
    @StateObject private var viewModel: RecordPlanViewModel
    @State private var isTraining = false
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: RecordPlanViewModel(context: context))
    }

    var body: some View {
        VStack {
            // 计时模块
            VStack {
                Text("训练计时")
                    .font(.title2)
                    .bold()
                Text(elapsedTimeString())
                    .font(.largeTitle)
                    .monospacedDigit()
                    .padding(.bottom, 16)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .shadow(radius: 2)
            .padding(.horizontal)

            // 开始/结束训练按钮
            Button(action: {
                if isTraining {
                    endTraining()
                } else {
                    startTraining()
                }
            }) {
                Text(isTraining ? "结束训练" : "开始训练")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isTraining ? Color.red : Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // 原有的主题列表
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.themes, id: \.id) { theme in
                        NavigationLink(destination: RecordThemeView(context: viewModel.managedObjectContext, theme: theme)) {
                            CardView(theme: theme)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("训练计时")
    }

    // 开始训练
    private func startTraining() {
        isTraining = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let startTime = startTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }

    // 结束训练
    private func endTraining() {
        isTraining = false
        timer?.invalidate()
        timer = nil
    }

    // 格式化时间显示
    private func elapsedTimeString() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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