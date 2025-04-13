import Foundation

struct TrainingTheme: Identifiable, Codable {
    var id: UUID
    var name: String
    var coverImage: Data?
    var note: String?
    var items: [TrainingItem]
    
    init(id: UUID = UUID(), name: String, coverImage: Data? = nil, note: String? = nil, items: [TrainingItem] = []) {
        self.id = id
        self.name = name
        self.coverImage = coverImage
        self.note = note
        self.items = items
    }
} 