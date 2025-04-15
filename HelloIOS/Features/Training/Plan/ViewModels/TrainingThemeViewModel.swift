import Foundation
import CoreData

class TrainingThemeViewModel: ObservableObject {
    @Published var theme: T_Theme
    @Published private(set) var itemsArray: [T_Item] = []
    let context: NSManagedObjectContext

    init(theme: T_Theme, context: NSManagedObjectContext) {
        self.theme = theme
        self.context = context
        self.itemsArray = theme.sortedItems // 初始化时加载排序后的 items
    }

    // 添加新的训练项目
    func addItem(name: String, note: String) {
        let newItem = T_Item(context: context)
        newItem.id = UUID()
        newItem.name = name
        newItem.note = note
        newItem.theme = theme // 建立与主题的关系

        theme.addToItems(newItem) // 更新主题的 items 集合
        saveContext()
        refreshItemsArray() // 更新 itemsArray
    }

    // 删除训练项目
    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let item = itemsArray[index]
            theme.removeFromItems(item) // 从主题的 items 集合中移除
            context.delete(item) // 从 Core Data 中删除
        }
        saveContext()
        refreshItemsArray() // 更新 itemsArray
    }

    // 更新主题备注
    func updateNoteText(_ noteText: String) {
        theme.note = noteText.isEmpty ? nil : noteText
        saveContext()
    }

    // 保存上下文
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }

    // 刷新 itemsArray
    private func refreshItemsArray() {
        itemsArray = theme.sortedItems
    }
}