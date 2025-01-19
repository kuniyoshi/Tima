import SwiftUI
import SwiftData

// Main view of measurement
struct MeasurementView: View {
    private enum Field {
        case task
        case work
    }

    @Environment(\.modelContext) private var modelContext
    @Query private var measurements: [Measurement]
    @Query private var tasks: [Tima.Task]
    @StateObject private var model: MeasurementModel
    @FocusState private var focusedField: Field?
    @State private var timer: Timer?

    var body: some View {
        VStack {
            HStack {
                TextField("Input group...", text: $model.taskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .task)
                    .padding()

                TextField("Input work...", text: $model.work)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .work)
                    .padding()

                Button("Focus Field") {
                    focusedField = .task
                }
                .keyboardShortcut("I", modifiers: [.command])
                .hidden()

                Text(model.isRunning ? model.elapsedSeconds : "")
                    .font(.headline.monospaced())
                    .padding()

                Button(
                    action: {
                        model.isRunning.toggle()

                        if model.isRunning {
                            model.startedAt = Date()
                        } else {
                            model.endedAt = Date()
                        }

                        assert(!model.isRunning || (model.isRunning && model.startedAt != nil))

                        if !model.isRunning,
                           let startedAt = model.startedAt,
                           let endedAt = model.endedAt {
                            do {
                                let task = try Tima.Task.findOrCreate(name: model.taskName, in: modelContext)
                                let measurement = Measurement(
                                    taskName: task.name,
                                    work: model.work,
                                    start: startedAt,
                                    end: endedAt
                                )

                                modelContext.insert(measurement)

                                try modelContext.save()
                            } catch {
                                model.alertDisplay = model.alertDisplay
                                    .weakWritten(title: "Error", message: "Failed to create measurement, or task: \(error)")
                            }
                        }

                        if model.isRunning {
                            let newTimer = Timer(timeInterval: 0.5, repeats: true) { _ in
                                DispatchQueue.main.async {
                                    onTick()
                                }
                            }
                            RunLoop.main.add(newTimer, forMode: .common)
                            timer = newTimer
                        } else {
                            timer?.invalidate()
                            timer = nil
                        }

                    }) {
                    Image(systemName: model.isRunning ? "stop.circle" : "play.circle")
                        .font(.title)
                }
                .padding()
            }

            Memory24HourHorizontalView(spans: makeSpans(measurements: measurements, tasks: tasks))
            .padding()

            ScrollViewReader { proxy in
                List {
                    ForEach(groupedMeasurements(measurements), id: \.self) { items in
                        MeasurementDailyList(measurements: items, tasks: tasks)
                    }
                }
                .onChange(of: measurements) {
                    if let lastId = measurements.last?.id {
                        proxy.scrollTo(lastId, anchor: .top)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)

            .alert(isPresented: .constant(model.alertDisplay.error != nil)) {
                assert(model.alertDisplay.error != nil)
                return Alert(
                    title: Text(model.alertDisplay.error?.title ?? "ERROR"),
                    message: Text(model.alertDisplay.error?.message ?? "Some error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    init(model: MeasurementModel) {
        _model = .init(wrappedValue: model)
    }

    private func onTick() {
        if let startedAt = model.startedAt {
            let duration = Int(Date().timeIntervalSince(startedAt))
            model.elapsedSeconds = "\(duration / 60):\(duration % 60)"
        }
    }

    private func makeSpans(measurements: [Measurement], tasks: [Tima.Task]) -> [(Int, Int, SwiftUI.Color)] {
        let from = Calendar.current.startOfDay(for: Date())
        let list = measurements.filter {
            $0.start >= from
        }
        return list.map { measurement in
            let minutes = Int(measurement.start.timeIntervalSince(from)) / 60
            let duration = Int(measurement.duration) / 60
            if let task = tasks.first(where: { $0.name == measurement.taskName }) {
                return (minutes, duration, task.color.uiColor)
            } else {
                return (minutes, duration, .black)
            }
        }
    }

    private func groupedMeasurements(_ measurements: [Measurement]) -> [[Measurement]] {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        let grouped = Dictionary(
            grouping: measurements.reversed()
        ) { measurement in
            Util.date(measurement.start)
        }

        return grouped.keys.sorted(by: >).map { key in
            grouped[key] ?? []
        }
    }
}

struct AlertDisplay {
    struct Error {
        var title: String
        var message: String
    }

    var error: Error?

    func cleared() -> AlertDisplay {
        AlertDisplay(error: nil)
    }

    func weakWritten(title: String, message: String) -> AlertDisplay {
        if let error {
            AlertDisplay(error: error)
        } else {
            AlertDisplay(error: Error(title: title, message: message))
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Schema([Tima.Task.self, Measurement.self]), configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    let taskA = Tima.Task(name: "task", color: .blue)
    let taskB = Tima.Task(name: "task2", color: .red)

    context.insert(taskA)
    context.insert(taskB)

    context.insert(
        Measurement(
            taskName: taskA.name,
            work: "work",
            start: Date(timeIntervalSinceNow: TimeInterval(-3600)),
            end: Date()
        )
    )
    context.insert(
        Measurement(
            taskName: taskB.name,
            work: "work",
            start: Date(timeIntervalSinceNow: -7200),
            end: Date(timeIntervalSinceNow: -3600)
        )
    )

    return MeasurementView(model: MeasurementModel())
        .modelContainer(container)
}
