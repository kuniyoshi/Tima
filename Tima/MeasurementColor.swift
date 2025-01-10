struct MeasurementColor: Codable, Hashable, Identifiable {
    static var red = MeasurementColor(red: 1.0, green: 0.0, blue: 0.0)
    static var magenta = MeasurementColor(red: 1.0, green: 0.0, blue: 1.0)
    static var cyan = MeasurementColor(red: 0.0, green: 1.0, blue: 1.0)
    static var green = MeasurementColor(red: 0.0, green: 1.0, blue: 0.0)
    static var blue = MeasurementColor(red: 0.0, green: 0.0, blue: 1.0)
    static var gray = MeasurementColor(red: 0.5, green: 0.5, blue: 0.5)

    static var allCases: [MeasurementColor] {
        [red, magenta, cyan, green, blue, gray]
    }

    var red: Double
    var green: Double
    var blue: Double

    var id: String {
        "\(red):\(green):\(blue)"
    }
}
