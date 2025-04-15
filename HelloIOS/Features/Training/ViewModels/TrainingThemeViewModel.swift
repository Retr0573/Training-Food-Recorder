import Foundation

class TrainingThemeViewModel: ObservableObject {
    @Published var theme: TrainingTheme
    private let planViewModel: TrainingPlanViewModel
    
    // 文件路径
    private var themeFilePath: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("theme_\(theme.id).json")
    }
    
    init(theme: TrainingTheme, planViewModel: TrainingPlanViewModel) {
        self.theme = theme
        self.planViewModel = planViewModel
        loadTheme()
    }
    
    // 加载主题数据
    private func loadTheme() {
        do {
            let data = try Data(contentsOf: themeFilePath)
            let loadedTheme = try JSONDecoder().decode(TrainingTheme.self, from: data)
            theme = loadedTheme
        } catch {
            print("Error loading theme: \(error)")
            // 如果加载失败，使用传入的主题
        }
    }
    
    // 保存主题数据
    private func saveTheme() {
        do {
            let data = try JSONEncoder().encode(theme)
            try data.write(to: themeFilePath)
        } catch {
            print("Error saving theme: \(error)")
        }
    }
    
    // 添加训练项目
    func addItem(_ item: TrainingItem) {
        var updatedTheme = theme
        updatedTheme.items.append(item)
        theme = updatedTheme
        saveTheme()  // 保存到本地文件
        planViewModel.updateThemeItems(updatedTheme.items, for: theme)  // 更新到全局数据
    }
    
    // 删除训练项目
    func deleteItem(_ item: TrainingItem) {
        var updatedTheme = theme
        updatedTheme.items.removeAll { $0.id == item.id }
        theme = updatedTheme
        saveTheme()  // 保存到本地文件
        planViewModel.updateThemeItems(updatedTheme.items, for: theme)  // 更新到全局数据
    }
    
    // 更新训练项目
    func updateItem(_ item: TrainingItem) {
        var updatedTheme = theme
        if let index = updatedTheme.items.firstIndex(where: { $0.id == item.id }) {
            updatedTheme.items[index] = item
            theme = updatedTheme
            saveTheme()  // 保存到本地文件
            planViewModel.updateThemeItems(updatedTheme.items, for: theme)  // 更新到全局数据
        }
    }
    
    // 移动训练项目
    func moveItem(from source: IndexSet, to destination: Int) {
        var updatedTheme = theme
        updatedTheme.items.move(fromOffsets: source, toOffset: destination)
        theme = updatedTheme
        saveTheme()  // 保存到本地文件
        planViewModel.updateThemeItems(updatedTheme.items, for: theme)  // 更新到全局数据
    }
    
    // 更新主题备注
    func updateThemeNote(_ note: String?) {
        var updatedTheme = theme
        updatedTheme.note = note
        theme = updatedTheme
        saveTheme()  // 保存到本地文件
        planViewModel.updateTheme(updatedTheme)  // 更新到全局数据
    }
} 