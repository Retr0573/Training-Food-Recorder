import Foundation
import CoreData

class TrainingItemViewModel: ObservableObject {
    @Published var item: T_Item
    @Published private(set) var setsArray: [T_Set] = []
    let context: NSManagedObjectContext

    init(item: T_Item, context: NSManagedObjectContext) {
        self.item = item
        self.context = context
        self.setsArray = item.getSets
    }

    func addSet(_ set: T_Set) {
        set.id = UUID()
        set.item = item
        
        // 设置新组的 order 值为当前最大 order + 1
        let maxOrder = setsArray.map { $0.order }.max() ?? -1
        set.order = maxOrder + 1
        
        item.addToSets(set)
        saveContext()
        refreshSetsArray()
    }

    func deleteSet(at offsets: IndexSet) {
        for index in offsets {
            let set = setsArray[index]
            item.removeFromSets(set)
            context.delete(set)
        }
        saveContext()
        refreshSetsArray()
    }

    func updateSet(_ set: T_Set) {
        saveContext()
        refreshSetsArray()
    }
    // 用于处理训练组的顺序调整，并更新 order 参数。
    func moveSet(from source: IndexSet, to destination: Int) {
        var reorderedSets = setsArray
        reorderedSets.move(fromOffsets: source, toOffset: destination)
        
        // 更新 order 参数
        for (index, set) in reorderedSets.enumerated() {
            set.order = Int16(index)
        }
        
        // 保存上下文并刷新数组
        saveContext()
        refreshSetsArray()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    private func refreshSetsArray() {
        setsArray = item.getSets.sorted(by: { $0.order < $1.order })
    }
}
// import Foundation

// class TrainingItemViewModel: ObservableObject {
//     @Published var item: TrainingItem
//     private let themeViewModel: TrainingThemeViewModel
    
//     // 文件路径
//     private var itemFilePath: URL {
//         let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//         return documentsDirectory.appendingPathComponent("item_\(item.id).json")
//     }
    
//     init(item: TrainingItem, themeViewModel: TrainingThemeViewModel) {
//         self.item = item
//         self.themeViewModel = themeViewModel
//         loadItem()
//     }
    
//     // 加载项目数据
//     private func loadItem() {
//         do {
//             let data = try Data(contentsOf: itemFilePath)
//             let loadedItem = try JSONDecoder().decode(TrainingItem.self, from: data)
//             item = loadedItem
//         } catch {
//             print("Error loading item: \(error)")
//             // 如果加载失败，使用传入的项目
//         }
//     }
    
//     // 保存项目数据
//     private func saveItem() {
//         do {
//             let data = try JSONEncoder().encode(item)
//             try data.write(to: itemFilePath)
//         } catch {
//             print("Error saving item: \(error)")
//         }
//     }
    
//     // 添加训练组
//     func addSet(_ set: TrainingSet) {
//         var updatedItem = item
//         updatedItem.sets.append(set)
//         item = updatedItem
//         saveItem()  // 保存到本地文件
//         themeViewModel.updateItem(updatedItem)  // 更新到主题数据
//     }
    
//     // 删除训练组
//     func deleteSet(_ set: TrainingSet) {
//         var updatedItem = item
//         updatedItem.sets.removeAll { $0.id == set.id }
//         item = updatedItem
//         saveItem()  // 保存到本地文件
//         themeViewModel.updateItem(updatedItem)  // 更新到主题数据
//     }
    
//     // 更新训练组
//     func updateSet(_ set: TrainingSet) {
//         var updatedItem = item
//         if let index = updatedItem.sets.firstIndex(where: { $0.id == set.id }) {
//             updatedItem.sets[index] = set
//             item = updatedItem
//             saveItem()  // 保存到本地文件
//             themeViewModel.updateItem(updatedItem)  // 更新到主题数据
//         }
//     }
    
//     // 移动训练组
//     func moveSet(from source: IndexSet, to destination: Int) {
//         var updatedItem = item
//         updatedItem.sets.move(fromOffsets: source, toOffset: destination)
//         item = updatedItem
//         saveItem()  // 保存到本地文件
//         themeViewModel.updateItem(updatedItem)  // 更新到主题数据
//     }
    
//     // 更新项目描述
//     func updateDescription(_ description: String?) {
//         var updatedItem = item
//         updatedItem.description = description
//         item = updatedItem
//         saveItem()  // 保存到本地文件
//         themeViewModel.updateItem(updatedItem)  // 更新到主题数据
//     }
// } 