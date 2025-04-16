import Foundation
import CoreData

class RecordItemViewModel: ObservableObject {
    @Published var sets: [SetState] = []
    private let context: NSManagedObjectContext
    private let item: T_Item
    private(set) var lastTrainedOrder: Int? = nil // 记录最后一个训练完成的 order

    init(context: NSManagedObjectContext, item: T_Item) {
        self.context = context
        self.item = item
        fetchSets()
    }
     var currentItem: T_Item {
        return item
    }
    func fetchSets() {
        let request: NSFetchRequest<T_Set> = T_Set.fetchRequest()
        request.predicate = NSPredicate(format: "item == %@", item)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \T_Set.order, ascending: true)]
        
        do {
            let fetchedSets = try context.fetch(request)
            sets = fetchedSets.map { SetState(set: $0) }
            updateLastTrainedOrder() // 初始化 lastTrainedOrder
        } catch {
            print("Failed to fetch sets: \(error)")
        }
    }

    func markSetAsTrained(_ setState: SetState) {
        setState.isTrained = true
        lastTrainedOrder = Int(setState.set.order) // 显式转换为 Int
    }

    private func updateLastTrainedOrder() {
        lastTrainedOrder = sets
            .filter { $0.isTrained }
            .map { Int($0.set.order) } // 显式转换为 Int
            .max()
    }
    func isSetStartable(_ setState: SetState) -> Bool {
        let order = Int(setState.set.order)
        return order == (lastTrainedOrder ?? -1) + 1 && !sets.contains { $0.isTraining }
    }
}

class SetState: ObservableObject, Identifiable {
    let set: T_Set
    @Published var isTrained: Bool = false
    @Published var isTraining: Bool = false
    @Published var elapsedTime: Int = 0 // 计时器时间
    @Published var trainingDuration: Int? = nil // 训练时长
    @Published var isResting: Bool = false // 是否处于休息状态
    @Published var remainingRestTime: Int = 0 // 剩余休息时间

    var id: UUID? { 
        return set.id 
    }
    
    // 回调：休息结束时触发
    var onRestingEnded: (() -> Void)?
    
    init(set: T_Set) {
        self.set = set
        self.remainingRestTime = Int(set.restTime) // 初始化为组间休息时间
    }
    // 检查是否需要结束休息状态
    func checkRestingStatus(isAnySetTraining: Bool) {
        if isAnySetTraining || remainingRestTime <= 0 {
            isResting = false
        }
    }
}