import SwiftUI

struct TrainingThemeView: View {
    @StateObject private var viewModel: TrainingThemeViewModel
    @State private var showingAddItem = false
    @State private var isEditingNote = false
    @State private var editingItem: TrainingItem?
    @State private var noteText: String
    
    init(theme: TrainingTheme, planViewModel: TrainingPlanViewModel) {
        _viewModel = StateObject(wrappedValue: TrainingThemeViewModel(theme: theme, planViewModel: planViewModel))
        _noteText = State(initialValue: theme.note ?? "")
    }
    
    var body: some View {
        List {
            // 主题信息区域
            Section {
                if let coverImage = viewModel.theme.coverImage,
                   let uiImage = UIImage(data: coverImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                }
                
                // 备注信息
                HStack {
                    Text("备注")
                    Spacer()
                    Text(viewModel.theme.note ?? "添加备注")
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    isEditingNote = true
                }
            }
            
            // 训练项目列表
            Section("训练项目") {
                ForEach(viewModel.theme.items) { item in
                    NavigationLink(destination: TrainingItemView(item: item, themeViewModel: viewModel)) {
                        ItemRowView(item: item)
                    }
                }
                .onMove { from, to in
                    viewModel.moveItem(from: from, to: to)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteItem(viewModel.theme.items[index])
                    }
                }
            }
        }
        .navigationTitle(viewModel.theme.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { 
                    editingItem = nil
                    showingAddItem = true 
                }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddItem) {
            TrainingItemFormView(
                item: editingItem,
                onSave: { item in
                    if let editingItem = editingItem {
                        viewModel.updateItem(item)
                    } else {
                        viewModel.addItem(item)
                    }
                    showingAddItem = false
                },
                onCancel: {
                    showingAddItem = false
                }
            )
        }
        .alert("编辑备注", isPresented: $isEditingNote) {
            TextField("备注", text: $noteText)
            Button("保存") {
                viewModel.updateThemeNote(noteText.isEmpty ? nil : noteText)
                isEditingNote = false
            }
            Button("取消", role: .cancel) {
                isEditingNote = false
            }
        }
    }
}

struct TrainingItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    let item: TrainingItem?
    let onSave: (TrainingItem) -> Void
    let onCancel: () -> Void
    
    @State private var name: String
    @State private var description: String
    @State private var sets: [TrainingSet]
    
    init(item: TrainingItem? = nil, onSave: @escaping (TrainingItem) -> Void, onCancel: @escaping () -> Void) {
        self.item = item
        self.onSave = onSave
        self.onCancel = onCancel
        _name = State(initialValue: item?.name ?? "")
        _description = State(initialValue: item?.description ?? "")
        _sets = State(initialValue: item?.sets ?? [])
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("项目名称", text: $name)
                    TextField("描述", text: $description)
                }

                // 这里暂时不实现训练组，训练组的添加在TrainingItemView中实现
                // Section(header: Text("训练组")) {
                //     ForEach(sets) { set in
                //         Text("\(set.reps) 次 × \(set.weight) kg")
                //     }
                //     .onDelete { indexSet in
                //         sets.remove(atOffsets: indexSet)
                //     }
                    
                //     Button(action: {
                //         sets.append(TrainingSet(reps: 10, weight: 0, restTime: 120))
                //     }) {
                //         Label("添加训练组", systemImage: "plus")
                //     }
                // }
                
            }
            .navigationTitle(item == nil ? "添加训练项目" : "编辑训练项目")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let newItem = TrainingItem(
                            id: item?.id ?? UUID(),
                            name: name,
                            description: description.isEmpty ? nil : description,
                            sets: sets
                        )
                        onSave(newItem)
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct ItemRowView: View {
    let item: TrainingItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)
            if let description = item.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text("\(item.sets.count) 组")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
