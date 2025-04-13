import Foundation

class TrainingPlanViewModel: ObservableObject {
    @Published var themes: [TrainingTheme] = []
    
    func addTheme(_ theme: TrainingTheme) {
        themes.append(theme)
        // TODO: 保存到本地存储
    }
    
    func deleteTheme(_ theme: TrainingTheme) {
        themes.removeAll { $0.id == theme.id }
        // TODO: 从本地存储中删除
    }
    
    func updateTheme(_ theme: TrainingTheme) {
        if let index = themes.firstIndex(where: { $0.id == theme.id }) {
            themes[index] = theme
            // TODO: 更新本地存储
        }
    }
}