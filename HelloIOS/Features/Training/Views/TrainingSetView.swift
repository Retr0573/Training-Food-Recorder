import SwiftUI

struct TrainingSetView: View {
    let set: TrainingSet
    let onSave: (TrainingSet) -> Void
    
    @State private var reps: Int
    @State private var weight: Double
    @State private var restTime: Int
    @State private var isWarmup: Bool
    
    init(set: TrainingSet, onSave: @escaping (TrainingSet) -> Void) {
        self.set = set
        self.onSave = onSave
        _reps = State(initialValue: set.reps)
        _weight = State(initialValue: set.weight)
        _restTime = State(initialValue: set.restTime)
        _isWarmup = State(initialValue: set.isWarmup)
    }
    
    var body: some View {
        Form {
            Section("训练组设置") {
                Stepper("重复次数: \(reps)", value: $reps, in: 1...100)
                HStack {
                    Text("重量")
                    Slider(value: $weight, in: 0...200, step: 2.5)
                    Text("\(String(format: "%.1f", weight))kg")
                }
                Stepper("休息时间: \(restTime)秒", value: $restTime, in: 0...300, step: 15)
                Toggle("热身组", isOn: $isWarmup)
            }
        }
        .navigationTitle("编辑训练组")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    let updatedSet = TrainingSet(
                        id: set.id,
                        reps: reps,
                        weight: weight,
                        restTime: restTime,
                        isWarmup: isWarmup
                    )
                    onSave(updatedSet)
                }
            }
        }
    }
}