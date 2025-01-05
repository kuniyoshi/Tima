import SwiftUI
import SwiftData

struct MeasurementView: View {
    private enum Field {
        case genre
        case work
    }

    @Environment(\.modelContext) private var modelContext
    @Query private var measurements: [Measurement]
    @State private var genre: String = ""
    @State private var work: String = ""
    @State private var isRunning: Bool = false
    @State private var startedAt: Date?
    @State private var endedAt: Date?
    @State private var alertDisplay = AlertDisplay(error: nil)
    @FocusState private var focusedField: Field?
    @State private var elapsedSeconds: String = ""
    @State private var timer: Timer?

    var body: some View {
        VStack {
            HStack {
                TextField("Input genre...", text: $genre)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .genre)
                    .padding()

                TextField("Input work...", text: $work)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .work)
                    .padding()

                Button("Focus Field") {
                    focusedField = .genre
                }
                .keyboardShortcut("I", modifiers: [.command])
                .hidden()

                Text(isRunning ? elapsedSeconds : "")
                    .font(.headline.monospaced())
                    .padding()

                Button(
                    action: {
                        isRunning.toggle()

                        if isRunning {
                            startedAt = Date()
                        } else {
                            endedAt = Date()
                        }

                        assert(!isRunning || (isRunning && startedAt != nil))

                        if !isRunning,
                           let startedAt,
                           let endedAt {
                            let measurement = Measurement(
                                genre: genre,
                                work: work,
                                start: startedAt,
                                end: endedAt
                            )
                            modelContext.insert(measurement)
                            do {
                                try modelContext.save()
                            } catch {
                                print("Failed to save mesurement: \(error)")
                                alertDisplay = alertDisplay
                                    .weakWritten(title: "ERROR", message: "Failed to save measurement: \(error)")
                            }
                        }

                        if isRunning {
                            timer = Timer
                                .scheduledTimer(
                                    withTimeInterval: 0.5,
                                    repeats: true
                                ) { _ in
                                    if let startedAt {
                                        let duration = Int(Date().timeIntervalSince(startedAt))
                                        elapsedSeconds = "\(duration / 60):\(duration % 60)"
                                    }
                                }
                        } else {
                            timer?.invalidate()
                            timer = nil
                        }

                    }) {
                        Image(systemName: isRunning ? "stop.circle" : "play.circle")
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

            .alert(isPresented: .constant(alertDisplay.error != nil)) {
                assert(alertDisplay.error != nil)
                return Alert(
                    title: Text(alertDisplay.error?.title ?? "ERROR"),
                    message: Text(alertDisplay.error?.message ?? "Some error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
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

        return grouped.keys.sorted().map { key in
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

    context.insert(Measurement(genre: "asdf", work: "work", start: Date(), end: Date()))

    return MeasurementView()
        .modelContainer(container)
}
