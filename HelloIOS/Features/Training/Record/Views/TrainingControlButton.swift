import SwiftUI

struct TrainingControlButton: View {
    @EnvironmentObject var timerManager: TrainingTimerManager

    var body: some View {
        Button(action: {
            if timerManager.isTraining {
                timerManager.endTraining()
            } else {
                timerManager.startTraining()
            }
        }) {
            VStack {
                Text(timerManager.isTraining ? "结束训练" : "开始训练")
                    .font(.headline)
                    .foregroundColor(.white)
                if timerManager.isTraining {
                    Text(timerManager.elapsedTimeString())
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(timerManager.isTraining ? Color.red : Color.green)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}