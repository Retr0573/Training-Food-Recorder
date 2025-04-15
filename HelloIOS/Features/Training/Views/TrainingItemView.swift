import SwiftUI

struct TrainingItemView: View {
    @StateObject private var viewModel: TrainingItemViewModel
    @State private var showingAddSet = false
    @State private var isEditingDescription = false
    @State private var descriptionText: String
    
    init(item: TrainingItem, themeViewModel: TrainingThemeViewModel) {
        _viewModel = StateObject(wrappedValue: TrainingItemViewModel(item: item, themeViewModel: themeViewModel))
        _descriptionText = State(initialValue: item.description ?? "")
    }
    
    var body: some View {
        List {
            // 项目描述
            Section {
                HStack {
                    Text("说明")
                    Spacer()
                    Text(viewModel.item.description ?? "添加说明")
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    isEditingDescription = true
                }
            }
            
            // 训练组列表
            Section("训练组") {
                ForEach(viewModel.item.sets) { set in
                    NavigationLink(destination: TrainingSetView(set: set, onSave: { updatedSet in
                        viewModel.updateSet(updatedSet)
                    })) {
                        SetRowView(set: set)
                    }
                }
                .onMove { from, to in
                    viewModel.moveSet(from: from, to: to)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteSet(viewModel.item.sets[index])
                    }
                }
            }
        }
        .navigationTitle(viewModel.item.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSet = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddSet) {
            AddSetFormView(
                onSave: { set in
                    viewModel.addSet(set)
                    showingAddSet = false
                },
                onCancel: {
                    showingAddSet = false
                }
            )
        }
        .alert("编辑说明", isPresented: $isEditingDescription) {
            TextField("说明", text: $descriptionText)
            Button("保存") {
                viewModel.updateDescription(descriptionText.isEmpty ? nil : descriptionText)
                isEditingDescription = false
            }
            Button("取消", role: .cancel) {
                isEditingDescription = false
            }
        }
    }
}

struct SetRowView: View {
    let set: TrainingSet
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(set.reps) 次 × \(String(format: "%.1f", set.weight))kg")
                    .font(.headline)
                Text("休息 \(set.restTime)秒")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if set.isWarmup {
                Text("热身组")
                    .font(.caption)
                    .padding(4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddSetFormView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (TrainingSet) -> Void
    let onCancel: () -> Void
    
    @State private var reps = 10
    @State private var weight = 20.0
    @State private var restTime = 60
    @State private var isWarmup = false
    
    var body: some View {
        NavigationView {
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
            .navigationTitle("添加训练组")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let newSet = TrainingSet(
                            reps: reps,
                            weight: weight,
                            restTime: restTime,
                            isWarmup: isWarmup
                        )
                        onSave(newSet)
                    }
                }
            }
        }
    }
}