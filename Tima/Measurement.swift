import Foundation
import SwiftData

@Model
final class Measurement: Codable {
    private static let iso8601DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }()

    var id: UUID
    var genre: String
    var work: String
    var start: Date
    var end: Date

    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case genre
        case work
        case start
        case end
    }

    init(id: UUID = UUID(), genre: String, work: String, start: Date, end: Date) {
        self.id = id
        self.genre = genre
        self.work = work
        self.start = start
        self.end = end
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        genre = try container.decode(String.self, forKey: .genre)
        work = try container.decode(String.self, forKey: .work)

        let startString = try container.decode(String.self, forKey: .start)
        let endString = try container.decode(String.self, forKey: .end)

        guard let startDate = Measurement.iso8601DateFormatter.date(from: startString),
              let endDate = Measurement.iso8601DateFormatter.date(from: endString) else {
            throw DecodingError.dataCorruptedError(forKey: .start, in: container, debugDescription: "Could not decode start: \(startString)")
        }

        start = startDate
        end = endDate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(genre, forKey: .genre)
        try container.encode(work, forKey: .work)
        try container.encode(Measurement.iso8601DateFormatter.string(from: start), forKey: .start)
        try container.encode(Measurement.iso8601DateFormatter.string(from: end), forKey: .end)
    }
}
