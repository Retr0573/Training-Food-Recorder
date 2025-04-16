import Foundation
import CoreData

class RecordItemViewModel: ObservableObject {
    @Published var sets: [T_Set] = []
    private let context: NSManagedObjectContext
    private let item: T_Item

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
            sets = try context.fetch(request)
        } catch {
            print("Failed to fetch sets: \(error)")
        }
    }
}