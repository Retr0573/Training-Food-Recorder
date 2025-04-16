import Foundation
import CoreData

// 负责从 Core Data 中获取 T_Theme 数据。
// 使用 @Published 属性将数据绑定到视图。
// 提供了 fetchThemes() 方法以便重新加载数据。
class RecordPlanViewModel: ObservableObject {
    @Published var themes: [T_Theme] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchThemes()
    }
    var managedObjectContext: NSManagedObjectContext {
        return context
    }
    func fetchThemes() {
        let request: NSFetchRequest<T_Theme> = T_Theme.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \T_Theme.name, ascending: true)]
        
        do {
            themes = try context.fetch(request)
        } catch {
            print("Failed to fetch themes: \(error)")
        }
    }
}