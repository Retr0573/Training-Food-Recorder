import Foundation
import CoreData
// 负责从 Core Data 中获取与某个 T_Theme 相关的 T_Item 数据。
// 使用 @Published 属性将数据绑定到视图。
class RecordThemeViewModel: ObservableObject {
    @Published var items: [T_Item] = []
    private let context: NSManagedObjectContext
    private let theme: T_Theme

    init(context: NSManagedObjectContext, theme: T_Theme) {
        self.context = context
        self.theme = theme
        fetchItems()
    }
    var currentTheme: T_Theme {
        return theme
    }
    var managedObjectContext: NSManagedObjectContext {
        return context
    }
    func fetchItems() {
        let request: NSFetchRequest<T_Item> = T_Item.fetchRequest()
        request.predicate = NSPredicate(format: "theme == %@", theme)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \T_Item.name, ascending: true)]
        
        do {
            items = try context.fetch(request)
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
}