import SwiftUI
import SwiftData
import Combine

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
        .onAppear {
            StatusBarController.shared.bind(to: timeBoxModel)
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
                switch measurementModel.buffer.isRunning {
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

                Button(action: {
                    NSApplication.shared.keyWindow?.makeFirstResponder(nil)
                }) {
                    EmptyView()
                }
                .hidden()
                .keyboardShortcut(.escape, modifiers: [])
            }
        }
    }

    init(database: Database, onRefreshDate: AnyPublisher<Void, Never>, onTerminate: AnyPublisher<Void, Never>) {
        self.database = database
        _measurementModel = .init(
            wrappedValue: MeasurementModel(database: database, onTerminate: onTerminate)
        )
        _timeBoxModel = .init(
            wrappedValue: TimeBoxModel(
                database: database,
                onRefreshDate: onRefreshDate,
                onTerminate: onTerminate
            )
        )
    }
}

#Preview {
    let schema = Schema([
        ImageColor.self,
        Measurement.self,
        TimeBox.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let subject = PassthroughSubject<Void, Never>()
        return ContentView(
            database: Database(
                modelContext: container.mainContext,
                onRefreshDate: subject.eraseToAnyPublisher(),
                onRefreshAll: subject.eraseToAnyPublisher()
            ),
            onRefreshDate: subject.eraseToAnyPublisher(),
            onTerminate: subject.eraseToAnyPublisher()
        )
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
