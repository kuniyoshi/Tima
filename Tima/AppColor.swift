import SwiftUI

// Codable Color to export application's data
struct AppColor: Codable, Hashable, Identifiable {
    static let blue = Self(red: 0.0, green: 0.0, blue: 1.0)
    static let brown = Self(red: 0.6, green: 0.4, blue: 0.2)
    static let cyan = Self(red: 0.0, green: 1.0, blue: 1.0)
    static let gray = Self(red: 0.5, green: 0.5, blue: 0.5)
    static let green = Self(red: 0.0, green: 1.0, blue: 0.0)
    static let indigo = Self(red: 0.29, green: 0.0, blue: 0.51)
    static let mint = Self(red: 0.6, green: 1.0, blue: 0.8)
    static let orange = Self(red: 1.0, green: 0.65, blue: 0.0)
    static let pink = Self(red: 1.0, green: 0.75, blue: 0.8)
    static let purple = Self(red: 0.5, green: 0.0, blue: 0.5)
    static let red = Self(red: 1.0, green: 0.0, blue: 0.0)
    static let teal = Self(red: 0.0, green: 0.5, blue: 0.5)
    static let yellow = Self(red: 1.0, green: 1.0, blue: 0.0)

    static var allCases: [Self] {
        [blue, brown, cyan, gray, green, indigo, mint, orange, pink, purple, red, teal, yellow]
    }

    static var random: Self {
        allCases.randomElement()!
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
