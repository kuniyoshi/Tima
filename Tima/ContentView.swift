import SwiftUI
import SwiftData

// Main view
struct ContentView: View {
    private enum MenuItem: String, CaseIterable {
        case measurement = "Measurement"
        case timeBox = "Time Box"
    }

    @State private var selection = MenuItem.measurement
    @StateObject private var measurementModel: MeasurementModel
    @StateObject private var timeBoxModel:TimeBoxModel

    private let database: Database

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
            ToolbarItem {
                switch measurementModel.isRunning {
                    case true:
                        Image(systemName: "ruler")
                            .padding()
                    case false:
                        EmptyView()
                }
            }
            ToolbarItem {
                if timeBoxModel.isStateRunning {
                    Image(systemName: "alarm")
                        .padding()
                } else {
                    EmptyView()
                }
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

    init(database: Database) {
        self.database = database
        _measurementModel = .init(wrappedValue: MeasurementModel(database: database))
        _timeBoxModel = .init(wrappedValue: TimeBoxModel(database: database))
    }
}

#Preview {
    let schema = Schema([
        Tima.Task.self,
        Measurement.self,
        TimeBox.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        return ContentView(database: Database(modelContext: container.mainContext))
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
