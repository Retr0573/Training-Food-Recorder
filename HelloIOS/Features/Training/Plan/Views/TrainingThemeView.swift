import SwiftUI
import CoreData

struct TrainingThemeView: View {
    @StateObject private var viewModel: TrainingThemeViewModel
    @State private var showingAddItem = false
    @State private var isEditingNote = false
    @State private var noteText: String

    init(theme: T_Theme, context: NSManagedObjectContext) {
        let createdViewModel = TrainingThemeViewModel(theme: theme, context: context)
        _viewModel = StateObject(wrappedValue: createdViewModel)
        
        let initialNoteText = theme.note ?? ""
        _noteText = State(initialValue: initialNoteText)
    }

    var body: some View {
        List {
            NoteSection(
                note: viewModel.theme.note,
                onEdit: { isEditingNote = true }
            )
            TrainingItemsSection(
                items: viewModel.itemsArray,
                onDelete: viewModel.deleteItem,
                context: viewModel.context // 传递 context
            )
        }
        .navigationTitle(viewModel.theme.name ?? "未命名主题")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(onSave: { name, note in
                if !name.isEmpty { // 确保只有在名称不为空时才添加项目
                    viewModel.addItem(name: name, note: note)
                }
                showingAddItem = false
            })
        }
        .alert("编辑备注", isPresented: $isEditingNote) {
            TextField("备注", text: $noteText)
            Button("保存") {
                viewModel.updateNoteText(noteText)
                isEditingNote = false
            }
            Button("取消", role: .cancel) {
                isEditingNote = false
            }
        }
    }
}
struct AddItemView: View {
    @State private var itemName = ""
    @State private var itemNote = ""
    let onSave: (String, String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("项目信息")) {
                    TextField("项目名称", text: $itemName)
                        .disableAutocorrection(true) // 禁用自动纠正，减少输入系统干扰
                    TextField("项目描述", text: $itemNote)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("添加训练项目")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onSave("", "") // 取消时传递空值
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(itemName, itemNote)
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
}

struct NoteSection: View {
    let note: String?
    let onEdit: () -> Void

    var body: some View {
        Section(header: Text("备注")) {
            HStack {
                Text(note ?? "暂无备注")
                    .foregroundColor(note == nil ? .secondary : .primary)
                Spacer()
                Button("编辑") {
                    onEdit()
                }
            }
        }
    }
}

struct TrainingItemsSection: View {
    let items: [T_Item]
    let onDelete: (IndexSet) -> Void
    let context: NSManagedObjectContext // 添加 context 参数

    var body: some View {
        Section(header: Text("训练项目")) {
            ForEach(items) { item in
                NavigationLink(destination: TrainingItemView(item: item, context: context)) { // 使用传递的 context
                    Text(item.name ?? "未命名项目")
                }
            }
            .onDelete(perform: onDelete)
        }
    }
}