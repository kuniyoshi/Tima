import SwiftUI

// Codable Color to export application's data
struct Color: Codable, Hashable, Identifiable {
    static let blue = Self(red: 0.0, green: 0.0, blue: 1.0)
    static let brown = Self()
    static let cyan = Self(red: 0.0, green: 1.0, blue: 1.0)
    static let gray = Self(red: 0.5, green: 0.5, blue: 0.5)
    static let green = Self(red: 0.0, green: 1.0, blue: 0.0)
    static let indigo = Self()
    static let mint = Self()
    static let orange = Self()
    static let pink = Self()
    static let purple = Self()
    static let red = Self(red: 1.0, green: 0.0, blue: 0.0)
    static let teal = Self(red: 1.0, green: 0.0, blue: 0.0)
    static let yellow = Self(red: 1.0, green: 0.0, blue: 0.0)

    static var allCases: [Self] {
        [blue, brown, cyan, gray, green, indigo, mint, orange, pink, purple, red, teal, yellow]
    }

    var red: Double
    var green: Double
    var blue: Double

    var id: String {
        "\(red):\(green):\(blue)"
    }

    var uiColor: SwiftUI.Color {
        .init(red: red, green: green, blue: blue)
    }
}
