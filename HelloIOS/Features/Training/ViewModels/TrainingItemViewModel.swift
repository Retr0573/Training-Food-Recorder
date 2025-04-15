import Foundation

class TrainingItemViewModel: ObservableObject {
    @Published var item: TrainingItem
    private let themeViewModel: TrainingThemeViewModel
    
    // 文件路径
    private var itemFilePath: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("item_\(item.id).json")
    }
    
    init(item: TrainingItem, themeViewModel: TrainingThemeViewModel) {
        self.item = item
        self.themeViewModel = themeViewModel
        loadItem()
    }
    
    // 加载项目数据
    private func loadItem() {
        do {
            let data = try Data(contentsOf: itemFilePath)
            let loadedItem = try JSONDecoder().decode(TrainingItem.self, from: data)
            item = loadedItem
        } catch {
            print("Error loading item: \(error)")
            // 如果加载失败，使用传入的项目
        }
    }
    
    // 保存项目数据
    private func saveItem() {
        do {
            let data = try JSONEncoder().encode(item)
            try data.write(to: itemFilePath)
        } catch {
            print("Error saving item: \(error)")
        }
    }
    
    // 添加训练组
    func addSet(_ set: TrainingSet) {
        var updatedItem = item
        updatedItem.sets.append(set)
        item = updatedItem
        saveItem()  // 保存到本地文件
        themeViewModel.updateItem(updatedItem)  // 更新到主题数据
    }
    
    // 删除训练组
    func deleteSet(_ set: TrainingSet) {
        var updatedItem = item
        updatedItem.sets.removeAll { $0.id == set.id }
        item = updatedItem
        saveItem()  // 保存到本地文件
        themeViewModel.updateItem(updatedItem)  // 更新到主题数据
    }
    
    // 更新训练组
    func updateSet(_ set: TrainingSet) {
        var updatedItem = item
        if let index = updatedItem.sets.firstIndex(where: { $0.id == set.id }) {
            updatedItem.sets[index] = set
            item = updatedItem
            saveItem()  // 保存到本地文件
            themeViewModel.updateItem(updatedItem)  // 更新到主题数据
        }
    }
    
    // 移动训练组
    func moveSet(from source: IndexSet, to destination: Int) {
        var updatedItem = item
        updatedItem.sets.move(fromOffsets: source, toOffset: destination)
        item = updatedItem
        saveItem()  // 保存到本地文件
        themeViewModel.updateItem(updatedItem)  // 更新到主题数据
    }
    
    // 更新项目描述
    func updateDescription(_ description: String?) {
        var updatedItem = item
        updatedItem.description = description
        item = updatedItem
        saveItem()  // 保存到本地文件
        themeViewModel.updateItem(updatedItem)  // 更新到主题数据
    }
} 