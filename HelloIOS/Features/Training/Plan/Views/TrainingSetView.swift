import SwiftUI
import CoreData

struct TrainingSetView: View {
    @StateObject private var viewModel: TrainingSetViewModel
    let onSave: (T_Set) -> Void

    init(set: T_Set?, context: NSManagedObjectContext, onSave: @escaping (T_Set) -> Void) {
        _viewModel = StateObject(wrappedValue: TrainingSetViewModel(set: set, context: context))
        self.onSave = onSave
    }

    var body: some View {
        Form {
            Section("训练组设置") {
                Stepper("重复次数: \(viewModel.reps)", value: $viewModel.reps, in: 1...100)
                HStack {
                    Text("重量")
                    Slider(value: $viewModel.weight, in: 0...200, step: 2.5)
                    Text("\(String(format: "%.1f", viewModel.weight))kg")
                }
                Stepper("休息时间: \(viewModel.restTime)秒", value: $viewModel.restTime, in: 0...300, step: 15)
                Toggle("热身组", isOn: $viewModel.isWarmup)
            }
        }
        .navigationTitle(viewModel.set == nil ? "添加训练组" : "编辑训练组")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    let updatedSet = viewModel.saveSet()
                    onSave(updatedSet)
                }
            }
        }
    }
}
