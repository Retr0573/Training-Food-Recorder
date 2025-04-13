import SwiftUI

struct TrainingThemeView: View {
    @StateObject private var viewModel = TrainingPlanViewModel()
    @State private var showingAddItem = false
    @State private var isEditingNote = false
    let theme: TrainingTheme
    
    var body: some View {
        List {
            // 主题信息区域
            Section {
                if let coverImage = theme.coverImage,
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
                    Text(theme.note ?? "添加备注")
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    isEditingNote = true
                }
            }
            
            // 训练项目列表
            Section("训练项目") {
                ForEach(theme.items) { item in
                    NavigationLink(destination: TrainingItemView(item: item)) {
                        ItemRowView(item: item)
                    }
                }
                .onMove { from, to in
                    // TODO: 实现项目重排序
                }
                .onDelete { indexSet in
                    // TODO: 实现项目删除
                }
            }
        }
        .navigationTitle(theme.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddItem) {
            // TODO: 添加新训练项目的表单
        }
        .alert("编辑备注", isPresented: $isEditingNote) {
            // TODO: 实现备注编辑功能
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
