import Foundation
import SwiftData

// TimeBox model
@Model
final class TimeBox: Codable {
    private enum CodingKeys: String, CodingKey {
        case start
        case workMinutes
    }

    var start: Date
    var workMinutes: Int

    init(start: Date, workMinutes: Int) {
        self.start = start
        self.workMinutes = workMinutes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let startString = try container.decode(String.self, forKey: .start)

        guard let startDate = Util.iso8601DateFormatter.date(from: startString) else {
            throw DecodingError.dataCorruptedError(forKey: .start, in: container, debugDescription: "Could not decode start: \(startString)")
        }

        start = startDate
        workMinutes = try container.decode(Int.self, forKey: .workMinutes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Util.iso8601DateFormatter.string(from: start), forKey: .start)
        try container.encode(workMinutes, forKey: .workMinutes)
    }
}
