import SwiftUI
import Combine

class TrainingTimerManager: ObservableObject {
    @Published var isTraining: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    private var startTime: Date?
    private var timer: Timer?

    @Published var isProjectTraining: Bool = false
    @Published var projectElapsedTime: TimeInterval = 0
    private var projectStartTime: Date?
    private var projectTimer: Timer?

    // 整体训练计时
    func startTraining() {
        isTraining = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }

    func endTraining() {
        isTraining = false
        timer?.invalidate()
        timer = nil
    }

    func elapsedTimeString() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // 项目训练计时
    func startProjectTraining() {
        isProjectTraining = true
        projectStartTime = Date()
        projectTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let projectStartTime = self.projectStartTime else { return }
            self.projectElapsedTime = Date().timeIntervalSince(projectStartTime)
        }
    }

    func endProjectTraining() {
        isProjectTraining = false
        projectTimer?.invalidate()
        projectTimer = nil
    }

    func projectElapsedTimeString() -> String {
        let hours = Int(projectElapsedTime) / 3600
        let minutes = (Int(projectElapsedTime) % 3600) / 60
        let seconds = Int(projectElapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}