import CoreData

class PersistentController {
    static let shared = PersistentController()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "Model") // 确保这里的名称与 .xcdatamodeld 文件名一致
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}