import Foundation
import SwiftData
import SwiftUI
import AppKit

@Model
final class Measurement: Codable {
    struct Color: Codable {
        var red: Double
        var green: Double
        var blue: Double

        static var red: Color {
            Color(red: 1.0, green: 0.0, blue: 0.0)
        }

        static var magenta: Color {
            Color(red: 1.0, green: 0.0, blue: 1.0)
        }

        static var cyan: Color {
            Color(red: 0.0, green: 1.0, blue: 1.0)
        }

        static var green: Color {
            Color(red: 0.0, green: 1.0, blue: 0.0)
        }

        static var blue: Color {
            Color(red: 0.0, green: 0.0, blue: 1.0)
        }

        static var gray: Color {
            Color(red: 0.5, green: 0.5, blue: 0.5)
        }
    }

    var id: UUID
    var genre: String
    var work: String
    var start: Date
    var end: Date
    var color: Color

    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case genre
        case work
        case start
        case end
        case color
    }

    init(id: UUID = UUID(), genre: String, work: String, start: Date, end: Date, color: Color) {
        self.id = id
        self.genre = genre
        self.work = work
        self.start = start
        self.end = end
        self.color = color
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        genre = try container.decode(String.self, forKey: .genre)
        work = try container.decode(String.self, forKey: .work)

        let startString = try container.decode(String.self, forKey: .start)
        let endString = try container.decode(String.self, forKey: .end)

        guard let startDate = Util.iso8601DateFormatter.date(from: startString),
              let endDate = Util.iso8601DateFormatter.date(from: endString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .start,
                in: container,
                debugDescription: "Could not decode start: \(startString)"
            )
        }
        start = startDate
        end = endDate

        let rgb = try container.decode([Double].self, forKey: .color)
        guard rgb.count == 3 else {
            throw DecodingError.dataCorruptedError(
                forKey: .color,
                in: container,
                debugDescription: "Invalid RGBA array: \(rgb)"
            )
        }
        color = Color(
            red: rgb[0],
            green: rgb[1],
            blue: rgb[2]
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(genre, forKey: .genre)
        try container.encode(work, forKey: .work)
        try container.encode(
            Util.iso8601DateFormatter.string(from: start),
            forKey: .start
        )
        try container.encode(
            Util.iso8601DateFormatter.string(from: end),
            forKey: .end
        )
        try container.encode([color.red, color.green, color.blue], forKey: .color)
    }
}
