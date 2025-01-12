import SwiftUI

// Codable Color to export application's data
struct Color: Codable, Hashable, Identifiable {
    static let red = Self(red: 1.0, green: 0.0, blue: 0.0)
    static let magenta = Self(red: 1.0, green: 0.0, blue: 1.0)
    static let cyan = Self(red: 0.0, green: 1.0, blue: 1.0)
    static let green = Self(red: 0.0, green: 1.0, blue: 0.0)
    static let blue = Self(red: 0.0, green: 0.0, blue: 1.0)
    static let gray = Self(red: 0.5, green: 0.5, blue: 0.5)

    static var allCases: [Self] {
        [red, magenta, cyan, green, blue, gray]
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
