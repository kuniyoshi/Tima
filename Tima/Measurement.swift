import Foundation
import SwiftData

@Model
final class Measurement: Codable {
    var id: UUID
    var genre: String
    var work: String
    var start: Date
    var end: Date

    init(id: UUID = UUID(), genre: String, work: String, start: Date, end: Date) {
        self.id = id
        self.genre = genre
        self.work = work
        self.start = start
        self.end = end
    }

    enum CodingKeys: String, CodingKey {
        case id
        case genre
        case work
        case start
        case end
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        genre = try container.decode(String.self, forKey: .genre)
        work = try container.decode(String.self, forKey: .work)
        start = try container.decode(Date.self, forKey: .start)
        end = try container.decode(Date.self, forKey: .end)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(genre, forKey: .genre)
        try container.encode(work, forKey: .work)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
    }
}
