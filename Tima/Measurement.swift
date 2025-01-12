import Foundation
import SwiftData
import SwiftUI
import AppKit

// Model data to represent time measurement
@Model
final class Measurement: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case taskName
        case work
        case start
        case end
    }

    var id: UUID
    var taskName: String
    var work: String
    var start: Date
    var end: Date

    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    init(id: UUID = UUID(), taskName: String = "", work: String, start: Date, end: Date) {
        self.id = id
        self.taskName = taskName
        self.work = work
        self.start = start
        self.end = end
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        taskName = try container.decode(String.self, forKey: .taskName)
        work = try container.decode(String.self, forKey: .work)

        let startString = try container.decode(String.self, forKey: .start)
        let endString = try container.decode(String.self, forKey: .end)

        guard let startDate = Util.iso8601DateFormatter.date(from: startString),
              let endDate = Util.iso8601DateFormatter.date(from: endString)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .start,
                in: container,
                debugDescription: "Could not decode start: \(startString)"
            )
        }
        start = startDate
        end = endDate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(taskName, forKey: .taskName)
        try container.encode(work, forKey: .work)
        try container.encode(
            Util.iso8601DateFormatter.string(from: start),
            forKey: .start
        )
        try container.encode(
            Util.iso8601DateFormatter.string(from: end),
            forKey: .end
        )
    }
}
