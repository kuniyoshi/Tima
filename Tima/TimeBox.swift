import Foundation
import SwiftData

@Model
final class TimeBox: Codable {
    var start: Date
    var workMinutes: Int

    init(start: Date, workMinutes: Int) {
        self.start = start
        self.workMinutes = workMinutes
    }

    enum CodingKeys: String, CodingKey {
        case start
        case workMinutes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(Date.self, forKey: .start)
        workMinutes = try container.decode(Int.self, forKey: .workMinutes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(workMinutes, forKey: .workMinutes)
    }
}
