import SwiftUI

struct TimaColor: Codable, Hashable, Identifiable {
    static let red = TimaColor(red: 1.0, green: 0.0, blue: 0.0)
    static let magenta = TimaColor(red: 1.0, green: 0.0, blue: 1.0)
    static let cyan = TimaColor(red: 0.0, green: 1.0, blue: 1.0)
    static let green = TimaColor(red: 0.0, green: 1.0, blue: 0.0)
    static let blue = TimaColor(red: 0.0, green: 0.0, blue: 1.0)
    static let gray = TimaColor(red: 0.5, green: 0.5, blue: 0.5)

    static var allCases: [TimaColor] {
        [red, magenta, cyan, green, blue, gray]
    }

    var red: Double
    var green: Double
    var blue: Double

    var id: String {
        "\(red):\(green):\(blue)"
    }

    var uiColor: Color {
        .init(red: red, green: green, blue: blue)
    }
}
