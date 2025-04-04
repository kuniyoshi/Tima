import SwiftUI
import SwiftData
import Combine

// Main view of measurement
struct MeasurementView: View {
    private enum Field {
        case work
        case detail
    }

    @StateObject private var model: MeasurementModel
    @FocusState private var focusedField: Field?
    @State private var showAlert: Bool = false
    @State private var isStartEditing: Bool = false
    @FocusState private var isStartFocused: Bool
    @State private var startDate: Date?

    private var onPlay = PassthroughSubject<Measurement, Never>()
    private var onDelete = PassthroughSubject<Measurement, Never>()
    private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(model.bufferColor)

                    TextField("Input group...", text: $model.buffer.work)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focusedField, equals: .work)
                        .onSubmit(model.toggleRunning)

                    TextField("Input work...", text: $model.buffer.detail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focusedField, equals: .detail)
                        .onSubmit(model.toggleRunning)
                }
                .padding()

                Button("Focus Field") {
                    focusedField = .work
                }
                .keyboardShortcut("I", modifiers: [.command])
                .hidden()

                if let start = model.buffer.startedAt {
                    if isStartEditing {
                        DatePicker(
                            "",
                            selection: Binding( // TODO: model?
                                get: { start },
                                set: { newValue in model.updateStartedAt(newValue) }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .focused($isStartFocused)
                        .onChange(of: isStartFocused) { _, newValue in
                            if !newValue {
                                isStartEditing = false
//                                model.updateStartDate(model.startedAt)
                            }
                        }
                        .onAppear {
                            isStartFocused = true
                        }
                        .onSubmit {
                            isStartEditing = false
                        }
                        // TODO: disable, on stop
                    } else {
                        Text(start, format: Date.FormatStyle(time: .shortened))
                            .onTapGesture {
                                isStartEditing = true
                            }
                    }
                }

                Text(model.buffer.isRunning ? model.elapsedSeconds : "")
                    .font(.headline.monospaced())
                    .padding()

                Button(action: model.toggleRunning) {
                    Image(systemName: model.buffer.isRunning ? "stop.circle" : "play.circle")
                        .font(.title)
                }
                .padding()
            }

            Memory24HourHorizontalView(spans: model.spans)
                .padding()

            HStack {
                Spacer()
                MeasurementTotalTimeView(model: model.totalTimeModel)
            }

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

            .sheet(isPresented: $showAlert) {
                VStack {
                    Text(model.alertDisplay.error?.title ?? "ERROR")
                        .font(.headline)
                    Text(model.alertDisplay.error?.message ?? "Some error occurred")
                        .font(.caption)
                    Spacer()
                    Button(action: {
                        model.dismissAlert()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                .padding()
            }
            .onChange(of: model.alertDisplay) { _, newValue in
                showAlert = newValue.error != nil
            }
        }
        .task {
            model.workFinishModel.beginTick()
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

struct AlertDisplay: Equatable {
    struct Error: Equatable {
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
    let container = try! ModelContainer(for: Schema([ImageColor.self, Measurement.self]), configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    let workA = ImageColor(name: "task", color: .blue)
    let workB = ImageColor(name: "task2", color: .red)

    context.insert(workA)
    context.insert(workB)

    context.insert(
        Measurement(
            work: workA.name,
            detail: "work",
            start: Date(timeIntervalSinceNow: TimeInterval(-3600)),
            end: Date()
        )
    )
    context.insert(
        Measurement(
            work: workB.name,
            detail: "work",
            start: Date(timeIntervalSinceNow: -7200),
            end: Date(timeIntervalSinceNow: -3600)
        )
    )
    let subject = PassthroughSubject<Void, Never>()
    let database = Database(
        modelContext: context,
        onRefreshDate: subject.eraseToAnyPublisher(),
        onRefreshAll: subject.eraseToAnyPublisher()
    )
    let model = MeasurementModel(database: database, onTerminate: subject.eraseToAnyPublisher())

    return MeasurementView(model: model)
        .modelContainer(container)
}
