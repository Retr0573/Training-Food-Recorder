import SwiftUI

struct TrainingRecordButton: View {
    @EnvironmentObject var timerManager: TrainingTimerManager

    var body: some View {
        VStack {
            Text("训练计时")
                .font(.headline)
                .foregroundColor(.white)
            Text(timerManager.elapsedTimeString()) // 显示训练计时
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
