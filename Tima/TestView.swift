import SwiftUI
import AppKit

struct ColorView: View {
    struct MyColor: Codable, Hashable, Identifiable {
        var red: Double
        var green: Double
        var blue: Double

        var id: String {
            "\(red):\(green):\(blue)"
        }

        static var red = MyColor(red: 1.0, green: 0.0, blue: 0.0)
        static var magenta = MyColor(red: 1.0, green: 0.0, blue: 1.0)
        static var cyan = MyColor(red: 0.0, green: 1.0, blue: 1.0)
        static var green = MyColor(red: 0.0, green: 1.0, blue: 0.0)
        static var blue = MyColor(red: 0.0, green: 0.0, blue: 1.0)
        static var gray = MyColor(red: 0.5, green: 0.5, blue: 0.5)

        static var allCases: [MyColor] { [red, magenta, cyan, green, blue, gray] }
    }

    @Environment(\.modelContext) private var context
    @State private var measurement: Measurement

    @State private var color: Color
    @FocusState private var isColorFocused: Bool
    @State private var isColorEditing = false

    var body: some View {
        if isColorEditing {
            Picker("", selection: $color) {
                ForEach(MyColor.allCases, id: \.self) { myColor in
                    let converted = ColorView.convertColor(myColor)
                    Image(systemName: "circle.fill")
                        .foregroundColor(converted)
                        .tag(ColorView.convertColor(myColor))
                }
            }
            .pickerStyle(InlinePickerStyle())
            .onChange(of: color) { _, newValue in
                isColorEditing = false
                updateMeasurement {
                    measurement.color = ColorView.otherConvert(newValue)
                }
            }
            .onSubmit {
                isColorEditing = false
                updateMeasurement {
                    measurement.color = ColorView.otherConvert(color)
                }
            }
        } else {
            Image(systemName: "circle.fill")
                .foregroundColor(color)
                .onTapGesture {
                    isColorEditing = true
                }
        }
    }

    init(measurement: Measurement) {
        self.measurement = measurement
        self._color = State(initialValue: MeasurementItem.convertColor(measurement.color))
    }

    static func convertColor(_ color: MyColor) -> Color {
        Color(red: color.red, green: color.green, blue: color.blue)
    }

    static func otherConvert(_ color: Color) -> Measurement.Color {
        // SwiftUIのColorからNSColorを作成するわ
        let nsColor = NSColor(color)

        // macOSの場合は、colorSpaceがdeviceRGBじゃない場合もあるから変換しておくといいわ
        guard let deviceColor = nsColor.usingColorSpace(.deviceRGB) else {
            return Measurement.Color(red: 0, green: 0, blue: 0)
        }

        var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        deviceColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return Measurement.Color(red: Double(red),
                                 green: Double(green),
                                 blue: Double(blue))
    }

    private func updateMeasurement(_ update: () -> Void) {
        update()
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

#Preview {
    ColorView(measurement: Measurement(
        genre: "デザイン",
        work: "UIスケッチ",
        start: Date(),
        end: Date(timeInterval: 180, since: Date()),
        color: .gray
    ))
}
