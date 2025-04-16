import SwiftUI
import Combine

class TrainingTimerManager: ObservableObject {
    @Published var isTraining: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    private var startTime: Date?
    private var timer: Timer?

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
}