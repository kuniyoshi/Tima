import SwiftUI

struct ContentView: View {
    private enum MenuItem: String, CaseIterable {
        case measurement = "Measurement"
        case timeBox = "Time Box"
    }

    @State private var selection = MenuItem.measurement
    @StateObject private var measurementModel = MeasurementModel()
    @StateObject private var timeBoxModel = TimeBoxModel()

    var body: some View {
        VStack {
            switch selection {
                case .measurement:
                    MeasurementView(model: measurementModel)
                case .timeBox:
                    TimeBoxView(model: timeBoxModel)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker(selection: $selection, label: EmptyView()) {
                    ForEach(MenuItem.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .overlay {
            Group {
                Button(action: { selection = .measurement }) {
                    EmptyView()
                }
                .hidden()
                .keyboardShortcut("1", modifiers: .command)

                Button(action: { selection = .timeBox }) {
                    EmptyView()
                }
                .hidden()
                .keyboardShortcut("2", modifiers: .command)
            }
        }
    }
}

#Preview {
    ContentView()
}
