import SwiftUI
import CoreData

struct TrainingItemView: View {
    @StateObject private var viewModel: TrainingItemViewModel
    @State private var showingAddSet = false
    @State private var editingSet: T_Set?
    @State private var editMode: EditMode = .inactive // 使用 EditMode 类型

    init(item: T_Item, context: NSManagedObjectContext) {
        let createdViewModel = TrainingItemViewModel(item: item, context: context)
        _viewModel = StateObject(wrappedValue: createdViewModel)
    }

    var body: some View {
        List {
            Section(header: Text("项目描述")) {
                Text(viewModel.item.note ?? "暂无描述")
                    .foregroundColor(viewModel.item.note == nil ? .secondary : .primary)
            }

            Section(header: Text("训练组")) {
                ForEach(viewModel.setsArray.sorted(by: { $0.order < $1.order })) { set in
                    Button(action: {
                        editingSet = set
                    }) {
                        HStack {
                            Text("\(set.reps) 次 × \(String(format: "%.1f", set.weight))kg")
                            Spacer()
                            if set.isWarmup {
                                Text("热身组")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.yellow.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteSet)
                .onMove(perform: viewModel.moveSet) // 启用拖动排序
            }
        }
        .navigationTitle(viewModel.item.name ?? "未命名项目")
        .toolbar {
     
            ToolbarItemGroup(placement: .navigationBarTrailing) { // 使用 ToolbarItemGroup 将两个按钮放在右侧
                EditButton() // 编辑模式按钮
                Button(action: { showingAddSet = true }) {
                    Image(systemName: "plus") // 添加按钮
                }
            }
        }
        .environment(\.editMode, $editMode) // 修改绑定
        .sheet(isPresented: $showingAddSet) {
            NavigationView {
                TrainingSetView(set: nil, context: viewModel.context) { newSet in
                    viewModel.addSet(newSet)
                    showingAddSet = false
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showingAddSet = false
                        }
                    }
                }
            }
        }
        .sheet(item: $editingSet) { set in
            NavigationView {
                TrainingSetView(set: set, context: viewModel.context) { updatedSet in
                    viewModel.updateSet(updatedSet)
                    editingSet = nil
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            editingSet = nil
                        }
                    }
                }
            }
        }
    }
}
// struct SetRowView: View {
//     let set: TrainingSet
    
//     var body: some View {
//         HStack {
//             VStack(alignment: .leading) {
//                 Text("\(set.reps) 次 × \(String(format: "%.1f", set.weight))kg")
//                     .font(.headline)
//                 Text("休息 \(set.restTime)秒")
//                     .font(.subheadline)
//                     .foregroundColor(.secondary)
//             }
            
//             Spacer()
            
//             if set.isWarmup {
//                 Text("热身组")
//                     .font(.caption)
//                     .padding(4)
//                     .background(Color.yellow.opacity(0.2))
//                     .cornerRadius(4)
//             }
//         }
//         .padding(.vertical, 4)
//     }
// }

// struct AddSetFormView: View {
//     @Environment(\.dismiss) private var dismiss
//     let onSave: (TrainingSet) -> Void
//     let onCancel: () -> Void
    
//     @State private var reps = 10
//     @State private var weight = 20.0
//     @State private var restTime = 60
//     @State private var isWarmup = false
    
//     var body: some View {
//         NavigationView {
//             Form {
//                 Section("训练组设置") {
//                     Stepper("重复次数: \(reps)", value: $reps, in: 1...100)
//                     HStack {
//                         Text("重量")
//                         Slider(value: $weight, in: 0...200, step: 2.5)
//                         Text("\(String(format: "%.1f", weight))kg")
//                     }
//                     Stepper("休息时间: \(restTime)秒", value: $restTime, in: 0...300, step: 15)
//                     Toggle("热身组", isOn: $isWarmup)
//                 }
//             }
//             .navigationTitle("添加训练组")
//             .toolbar {
//                 ToolbarItem(placement: .cancellationAction) {
//                     Button("取消") {
//                         onCancel()
//                     }
//                 }
//                 ToolbarItem(placement: .confirmationAction) {
//                     Button("保存") {
//                         let newSet = TrainingSet(
//                             reps: reps,
//                             weight: weight,
//                             restTime: restTime,
//                             isWarmup: isWarmup
//                         )
//                         onSave(newSet)
//                     }
//                 }
//             }
//         }
//     }
// }
