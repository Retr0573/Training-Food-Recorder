import Foundation

class TrainingPlanViewModel: ObservableObject {
    @Published var themes: [TrainingTheme] = []
    
    // 文件路径：trainingThemes.json
    // 存储所有主题的完整信息
    // 包括每个主题的 items（训练项目）
    // 每次修改主题或项目时都会更新这个文件
    private var themesFilePath: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("trainingThemes.json")
    }
    
    // 初始化时加载数据
    init() {
        loadThemes()
    }
    
    // 加载主题数据
    private func loadThemes() {
        do {
            let data = try Data(contentsOf: themesFilePath)
            themes = try JSONDecoder().decode([TrainingTheme].self, from: data)
        } catch {
            print("Error loading themes: \(error)")
            themes = []  // 如果加载失败，使用空数组
        }
    }
    
    // 保存主题数据
    private func saveThemes() {
        do {
            let data = try JSONEncoder().encode(themes)
            try data.write(to: themesFilePath)
        } catch {
            print("Error saving themes: \(error)")
        }
    }
    
    // 添加主题
    func addTheme(_ theme: TrainingTheme) {
        themes.append(theme)
        saveThemes()  // 保存到文件
    }
    
    // 删除主题
    func deleteTheme(_ theme: TrainingTheme) {
        themes.removeAll { $0.id == theme.id }
        saveThemes()  // 保存到文件
    }
    
    // 更新主题
    func updateTheme(_ theme: TrainingTheme) {
        if let index = themes.firstIndex(where: { $0.id == theme.id }) {
            themes[index] = theme
            saveThemes()  // 保存到文件
        }
    }
    
    // 更新主题的项目列表
    func updateThemeItems(_ items: [TrainingItem], for theme: TrainingTheme) {
        if let index = themes.firstIndex(where: { $0.id == theme.id }) {
            var updatedTheme = theme
            updatedTheme.items = items
            themes[index] = updatedTheme
            saveThemes()
        }
    }
}