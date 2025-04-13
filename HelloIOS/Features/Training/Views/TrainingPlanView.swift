import SwiftUI

/*
Training Plan 主页面：
├── 查看列表：直接显示所有训练主题
├── 添加主题：点击右上角加号 → 打开表单 → 输入信息 → 保存/取消
├── 删除主题：左滑列表项 → 点击删除
└── 查看详情：点击列表项 → 导航到 TrainingThemeView
*/

// MARK: - 训练计划主视图
struct TrainingPlanView: View {
    // 使用 StateObject 创建视图模型实例，确保视图的生命周期内保持存在
    @StateObject private var viewModel = TrainingPlanViewModel()
    // 控制是否显示添加主题的表单
    @State private var showingAddTheme = false
    
    var body: some View {
        // 创建导航视图容器
        NavigationView {
            // 创建列表视图来显示所有训练主题
            List {
                // 遍历所有训练主题并创建可点击的导航链接
                ForEach(viewModel.themes) { theme in
                    NavigationLink(destination: TrainingThemeView(theme: theme)) {
                        ThemeRowView(theme: theme)
                    }
                }
                // 添加左滑删除功能
                .onDelete(perform: deleteThemes)
            }
            // 设置导航栏标题
            .navigationTitle("训练计划")
            // 添加导航栏按钮
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // 添加新主题的按钮
                    Button(action: { showingAddTheme = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // 当 showingAddTheme 为 true 时显示添加主题的表单
            .sheet(isPresented: $showingAddTheme) {
                AddThemeView(isPresented: $showingAddTheme, viewModel: viewModel)
            }
        }
    }
    
    // 处理主题删除的方法
    private func deleteThemes(at offsets: IndexSet) {
        offsets.forEach { index in
            viewModel.deleteTheme(viewModel.themes[index])
        }
    }
}

// MARK: - 添加主题表单视图
struct AddThemeView: View {
    // 用于控制表单显示状态的绑定变量
    @Binding var isPresented: Bool
    // 引用视图模型以进行数据操作
    @ObservedObject var viewModel: TrainingPlanViewModel
    // 用于存储用户输入的主题名称
    @State private var themeName = ""
    // 用于存储用户输入的主题备注
    @State private var themeNote = ""
    
    var body: some View {
        NavigationView {
            // 创建表单
            Form {
                Section(header: Text("主题信息")) {
                    // 主题名称输入框
                    TextField("主题名称", text: $themeName)
                    // 主题备注输入框（选填）
                    TextField("备注（可选）", text: $themeNote)
                }
            }
            // 设置表单标题
            .navigationTitle("新建训练主题")
            // 添加导航栏按钮
            .navigationBarItems(
                // 取消按钮：关闭表单
                leading: Button("取消") {
                    isPresented = false
                },
                // 保存按钮：创建新主题
                trailing: Button("保存") {
                    saveTheme()
                }
                // 当主题名称为空时禁用保存按钮
                .disabled(themeName.isEmpty)
            )
        }
    }
    
    // 保存新主题的方法
    private func saveTheme() {
        // 创建新的训练主题实例
        let newTheme = TrainingTheme(
            name: themeName,
            // 如果备注为空则设为 nil
            note: themeNote.isEmpty ? nil : themeNote
        )
        // 将新主题添加到视图模型中
        viewModel.addTheme(newTheme)
        // 关闭表单
        isPresented = false
    }
}

// MARK: - 主题列表项视图
struct ThemeRowView: View {
    // 接收要显示的训练主题数据
    let theme: TrainingTheme
    
    var body: some View {
        // 创建垂直堆栈来显示主题信息
        VStack(alignment: .leading) {
            // 显示主题名称
            Text(theme.name)
                .font(.headline)
            // 如果存在备注则显示
            if let note = theme.note {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        // 添加垂直内边距
        .padding(.vertical, 8)
    }
}
