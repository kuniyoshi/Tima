import Foundation
import SwiftData

// Color of data
@Model
final class ImageColor: Codable, Identifiable {
    private enum CodingKeys: String, CodingKey {
        case name
        case color
    }

    @Attribute(.unique) var name: String
    var color: Tima.AppColor

    init(name: String, color: Tima.AppColor) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.color = color
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)

        let rgb = try container.decode([Double].self, forKey: .color)
        guard rgb.count == 3 else {
            throw DecodingError.dataCorruptedError(
                forKey: .color,
                in: container,
                debugDescription: "Invalid RGBA array: \(rgb)"
            )
        }
        color = Tima.AppColor(
            red: rgb[0],
            green: rgb[1],
            blue: rgb[2]
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode([color.red, color.green, color.blue], forKey: .color)
    }
}
