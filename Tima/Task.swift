import Foundation
import SwiftData

struct Tima {
    @Model
    final class Task: Codable, Identifiable {
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case color
        }
        
        var id: UUID
        var name: String // TODO: @Attribute(.unique) 使える？
        var color: TimaColor
        
        init(id: UUID = UUID(), name: String, color: TimaColor) {
            self.id = id
            self.name = name
            self.color = color
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            
            let rgb = try container.decode([Double].self, forKey: .color)
            guard rgb.count == 3 else {
                throw DecodingError.dataCorruptedError(
                    forKey: .color,
                    in: container,
                    debugDescription: "Invalid RGBA array: \(rgb)"
                )
            }
            color = TimaColor(
                red: rgb[0],
                green: rgb[1],
                blue: rgb[2]
            )
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode([color.red, color.green, color.blue], forKey: .color)
        }
    }
}
