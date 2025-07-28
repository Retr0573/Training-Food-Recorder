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

    func duplicateSet(_ set: T_Set) {
        let newSet = T_Set(context: context)
        newSet.id = UUID()  // 确保有唯一ID
        newSet.item = item
        newSet.reps = set.reps
        newSet.weight = set.weight
        newSet.restTime = set.restTime
        newSet.isWarmup = set.isWarmup
        
        // 设置新组的顺序为当前最大顺序+1
        let maxOrder = setsArray.map { $0.order }.max() ?? -1
        newSet.order = maxOrder + 1
        
        // 建立双向关系
        item.addToSets(newSet)
        // 保存上下文
        saveContext()
        
        // 刷新数组以更新UI
        refreshSetsArray()
    }

    // /// 清理单向依赖的 Set
    // func cleanupOrphanedSets() {
    //     // 1. 通过 FetchRequest 获取与当前 item 相关的所有 Set
    //     let fetchRequest: NSFetchRequest<T_Set> = T_Set.fetchRequest()
    //     fetchRequest.predicate = NSPredicate(format: "item == %@", item)
        
    //     do {
    //         let allSets = try context.fetch(fetchRequest)
            
    //         // 2. 获取当前通过关系能够获取到的 Set
    //         let relatedSets = item.getSets
            
    //         // 3. 找出只有单向依赖的 Set（在 allSets 中但不在 relatedSets 中）
    //         let orphanedSets = allSets.filter { set in
    //             !relatedSets.contains { $0.id == set.id }
    //         }
            
    //         print("找到 \(orphanedSets.count) 个单向依赖的训练组")
            
    //         // 4. 删除这些单向依赖的 Set
    //         for set in orphanedSets {
    //             context.delete(set)
    //             print("删除了单向依赖的训练组: \(set.weight)kg x \(set.reps)次")
    //         }
            
    //         // 5. 保存上下文
    //         if !orphanedSets.isEmpty {
    //             saveContext()
    //             print("已删除所有单向依赖的训练组")
    //         }
    //     } catch {
    //         print("清理单向依赖的训练组时出错: \(error)")
    //     }
    // }

    private func saveContext() {
        do {
            try context.save()
            objectWillChange.send()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    private func refreshSetsArray() {
        setsArray = item.getSets.sorted(by: { $0.order < $1.order })
    }
}