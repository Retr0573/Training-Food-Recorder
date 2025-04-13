import Foundation

struct TrainingItem: Identifiable, Codable {
    var id: UUID
    var name: String
    var description: String?
    var sets: [TrainingSet]
    
    init(id: UUID = UUID(), name: String, description: String? = nil, sets: [TrainingSet] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.sets = sets
    }
} 