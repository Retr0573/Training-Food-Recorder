import Foundation
import CoreData

class TrainingSetViewModel: ObservableObject {
    @Published var reps: Int
    @Published var weight: Double
    @Published var restTime: Int
    @Published var isWarmup: Bool

    var set: T_Set?
    private var context: NSManagedObjectContext

    init(set: T_Set?, context: NSManagedObjectContext) {
        self.set = set
        self.context = context
        self.reps = Int(set?.reps ?? 10)
        self.weight = set?.weight ?? 20.0
        self.restTime = Int(set?.restTime ?? 120)
        self.isWarmup = set?.isWarmup ?? false
    }

    func saveSet() -> T_Set {
        let updatedSet = set ?? T_Set(context: context)
        updatedSet.reps = Int16(reps)
        updatedSet.weight = weight
        updatedSet.restTime = Int16(restTime)
        updatedSet.isWarmup = isWarmup

        do {
            try context.save()
        } catch {
            print("Error saving set: \(error.localizedDescription)")
        }

        return updatedSet
    }
}
