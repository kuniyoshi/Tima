import SwiftUI

struct Color: Codable, Hashable, Identifiable {
    static let red = Tima.Color(red: 1.0, green: 0.0, blue: 0.0)
    static let magenta = Tima.Color(red: 1.0, green: 0.0, blue: 1.0)
    static let cyan = Tima.Color(red: 0.0, green: 1.0, blue: 1.0)
    static let green = Tima.Color(red: 0.0, green: 1.0, blue: 0.0)
    static let blue = Tima.Color(red: 0.0, green: 0.0, blue: 1.0)
    static let gray = Tima.Color(red: 0.5, green: 0.5, blue: 0.5)

    static var allCases: [Tima.Color] {
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
