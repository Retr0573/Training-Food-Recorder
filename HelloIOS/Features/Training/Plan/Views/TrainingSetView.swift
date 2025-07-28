import SwiftUI
import CoreData

struct TrainingSetView: View {
    @StateObject private var viewModel: TrainingSetViewModel
    let onSave: (T_Set) -> Void
    @State private var isShowingWeightInput = false
    @State private var isShowingRestTimeInput = false
    @State private var tempWeightInput = ""
    @State private var tempRestTimeInput = ""

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
                        .foregroundColor(.blue)
                        .onTapGesture {
                            tempWeightInput = String(format: "%.1f", viewModel.weight)
                            isShowingWeightInput = true
                        }
                }
                
                HStack {
                    Text("休息时间: ")
                    Stepper("", value: $viewModel.restTime, in: 0...300, step: 15)
                    .labelsHidden()
                    Spacer()
                    Text("\(viewModel.restTime)秒")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            tempRestTimeInput = "\(viewModel.restTime)"
                            isShowingRestTimeInput = true
                        }
                }
                .padding(.vertical, 8)
                
                // Stepper("", value: $viewModel.restTime, in: 0...300, step: 15)
                //     .labelsHidden()
                
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
        .alert("输入重量 (kg)", isPresented: $isShowingWeightInput) {
            TextField("重量", text: $tempWeightInput)
                .keyboardType(.decimalPad)
            Button("取消", role: .cancel) {}
            Button("确定") {
                if let newWeight = Double(tempWeightInput.replacingOccurrences(of: ",", with: ".")) {
                    // 限制在滑块范围内
                    viewModel.weight = min(max(newWeight, 0), 200)
                }
            }
        }
        .alert("输入休息时间 (秒)", isPresented: $isShowingRestTimeInput) {
            TextField("休息时间", text: $tempRestTimeInput)
                .keyboardType(.numberPad)
            Button("取消", role: .cancel) {}
            Button("确定") {
                if let newRestTime = Int(tempRestTimeInput) {
                    // 限制在Stepper范围内
                    viewModel.restTime = min(max(newRestTime, 0), 300)
                }
            }
        }
    }
}
