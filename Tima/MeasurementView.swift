import SwiftUI
import SwiftData
import Combine

// Main view of measurement
struct MeasurementView: View {
    private enum Field {
        case task
        case work
    }

    @StateObject private var model: MeasurementModel
    @FocusState private var focusedField: Field?

    private var onPlay = PassthroughSubject<Measurement, Never>()
    private var onDelete = PassthroughSubject<Measurement, Never>()
    private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            HStack {
                TextField("Input group...", text: $model.taskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .task)
                    .onSubmit(model.toggleRunning)
                    .padding()

                TextField("Input work...", text: $model.work)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .work)
                    .onSubmit(model.toggleRunning)
                    .padding()

                Button("Focus Field") {
                    focusedField = .task
                }
                .keyboardShortcut("I", modifiers: [.command])
                .hidden()

                Text(model.isRunning ? model.elapsedSeconds : "")
                    .font(.headline.monospaced())
                    .padding()

                Button(action: model.toggleRunning) {
                    Image(systemName: model.isRunning ? "stop.circle" : "play.circle")
                        .font(.title)
                }
                .padding()
            }

            Memory24HourHorizontalView(spans: model.spans)
                .padding()

            ScrollViewReader { proxy in
                List {
                    HStack {
                        Spacer()
                        if let lastRemoved = model.lastRemoved {
                            Button(action: {
                                restoreRemoved(lastRemoved)
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                            }
                            .transition(.slide.combined(with: .opacity))
                        }
                    }

                    ForEach(model.dailyListModels, id: \.self.id) { model in
                        MeasurementDailyListView(model: model)
                    }
                }
                .onChange(of: model.measurements) {
                    if let lastId = model.measurements.last?.id {
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
        .onAppear {
            model.toggleRunning()
        }
    }

    init(model: MeasurementModel) {
        _model = .init(wrappedValue: model)
    }

    private func restoreRemoved(_ measurement: Measurement) {
        withAnimation {
            model.restoreRemoved(measurement: measurement)
        }
    }

    private func onDelete(measurement: Measurement) -> Void {
        withAnimation {
            model.delete(measurement: measurement)
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
    let database = Database(modelContext: context)

    return MeasurementView(model: MeasurementModel(database: database))
        .modelContainer(container)
}
