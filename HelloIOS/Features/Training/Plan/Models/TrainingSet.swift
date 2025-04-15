import Foundation

struct TrainingSet: Identifiable, Codable {
    var id: UUID
    var reps: Int
    var weight: Double
    var restTime: Int
    var isWarmup: Bool
    
    init(id: UUID = UUID(), reps: Int, weight: Double, restTime: Int, isWarmup: Bool = false) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.restTime = restTime
        self.isWarmup = isWarmup
    }
}