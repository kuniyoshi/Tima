import SwiftUI
import SwiftData

struct MeasurementView: View {
    private enum Field {
        case genre
        case work
    }

    @Environment(\.modelContext) private var modelContext
    @Query private var measurements: [Measurement]
    @StateObject private var model: MeasurementModel
    @FocusState private var focusedField: Field?
    @State private var timer: Timer?

    var body: some View {
        VStack {
            HStack {
                TextField("Input genre...", text: $model.genre)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .genre)
                    .padding()

                TextField("Input work...", text: $model.work)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .work)
                    .padding()

                Button("Focus Field") {
                    focusedField = .genre
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
                            let measurement = Measurement(
                                genre: model.genre,
                                work: model.work,
                                start: startedAt,
                                end: endedAt,
                                color: .blue
                            )
                            modelContext.insert(measurement)
                            do {
                                try modelContext.save()
                            } catch {
                                print("Failed to save mesurement: \(error)")
                                model.alertDisplay = model.alertDisplay
                                    .weakWritten(title: "ERROR", message: "Failed to save measurement: \(error)")
                            }
                        }

                        if model.isRunning {
                            timer = Timer
                                .scheduledTimer(
                                    withTimeInterval: 0.5,
                                    repeats: true
                                ) { _ in
                                    if let startedAt = model.startedAt {
                                        let duration = Int(Date().timeIntervalSince(startedAt))
                                        model.elapsedSeconds = "\(duration / 60):\(duration % 60)"
                                    }
                                }
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

            Memory24HourHorizontalView(spans: makeSpans(measurements))
                .onChange(of: measurements) {
                }
                .padding()

            ScrollViewReader { proxy in
                List {
                    ForEach(groupedMeasurements(measurements), id: \.self) { items in
                        MeasurementGroupItem(measurements: items)
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
        .toolbar {
            ToolbarItem {
                switch model.isRunning {
                    case true:
                        Image(systemName: "ruler")
                            .padding()
                    case false:
                        EmptyView()
                }
            }
        }
    }

    init(model: MeasurementModel) {
        _model = .init(wrappedValue: model)
    }

    private func makeSpans(_ measurements: [Measurement]) -> [(Int, Int)] {
        let from = Calendar.current.startOfDay(for: Date())
        let list = measurements.filter { $0.start >= from }
        return list.map { measurement in
            let minutes = Int(measurement.start.timeIntervalSince(from)) / 60
            let duration = Int(measurement.duration) / 60
            return (minutes, duration)
        }
    }

    private func groupedMeasurements(_ measurements: [Measurement]) -> [[Measurement]] {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        let grouped = Dictionary(
            grouping: measurements.reversed()
        ) { measurement in
            return formatter.string(from: measurement.start)
        }

        return grouped.keys.sorted(by: >).map { key in
            return grouped[key] ?? []
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
    let container = try! ModelContainer(for: Measurement.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    context.insert(Measurement(genre: "asdf", work: "work", start: Date(), end: Date(), color: .blue))

    return MeasurementView(model: MeasurementModel())
        .modelContainer(container)
}
