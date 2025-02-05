import SwiftUI
import SwiftData
import Combine

extension Notification.Name {
    static let modelContextDidChange = Notification.Name("modelContextDidChange")
}

struct QuxView: View {
    @StateObject private var model: QuxModel

    var body: some View {
        VStack {
            Text(model.elapsedSeconds.description)
                .padding()

            ScrollViewReader { proxy in
                List {
                    HStack {
                        Spacer()
                        if let lastRemoved = model.lastRemoved {
                            Button(action: {
                                model.restoreRemoved(lastRemoved)
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

//            .alert(isPresented: .constant(model.alertDisplay.error != nil)) {
//                assert(model.alertDisplay.error != nil)
//                return Alert(
//                    title: Text(model.alertDisplay.error?.title ?? "ERROR"),
//                    message: Text(model.alertDisplay.error?.message ?? "Some error occurred"),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
        }
        .onAppear {
            model.beginTick()
        }
    }

    init(model: QuxModel) {
        _model = .init(wrappedValue: model)
    }

}


@MainActor
class QuxModel: ObservableObject {
    enum Transaction {
        case begin
        case stop
        case resume(taskName: String, work: String)
    }

    @Published var isRunning: Bool = false
    @Published var taskName: String = ""
    @Published var work: String = ""
    @Published var startedAt: Date?
    @Published var endedAt: Date?
    @Published var elapsedSeconds: String = ""
    @Published var measurements: [Measurement] = []
    @Published var tasks: [Tima.Task] = []

//    private let modelContext: ModelContext
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    @Published var dailyListModels: [MeasurementDaillyListModel] = []
    @Published var lastRemoved: Measurement?

    private let database: Database

    init(database: Database) {
        self.database = database
        database.$groupedMeasurements
            .map { groupedMeasurements in
                groupedMeasurements.compactMap { pairs in QuxModel.createModel(items: pairs, onPlay: { _ in }, onDelete: { _ in }) }
//                return create(items: pairs)
            }
            .assign(to: &$dailyListModels)
    }

    func lateInit() {

    }

    static func createModel(items: [(Measurement, Tima.Task)], onPlay: @escaping (Measurement) -> Void, onDelete: @escaping (Measurement) -> Void) -> MeasurementDaillyListModel {
        return MeasurementDaillyListModel(
            pairs: items,
            onPlay: onPlay,
            onDelete: onDelete
        )
//        return MeasurementDaillyListModel(
//            pairs: items,
//            onPlay: { [unowned self] measurement in
//                self.processTransaction(transaction: .resume(taskName: measurement.taskName, work: measurement.work))
//            },
//            onDelete: { [unowned self] measurement in
//                self.onDelete(measurement: measurement)
//            }
//        )
    }

    private func setupBindings(onPlay: @escaping (Measurement) -> Void, onDelete: @escaping (Measurement) -> Void) {
    }

    func processTransaction(transaction: Transaction) {
        switch transaction {
            case .begin:
                isRunning = true
            case .stop:
                isRunning = false
            case .resume(let taskName, let work):
                if isRunning,
                   let newMeasurement = newMeasurementOnResume() {
                    saveMeasurement(newMeasurement)
                }
                begin(taskName: taskName, work: work)
        }

        if isRunning {
            startedAt = Date()
        } else {
            endedAt = Date()
        }

        assert(!isRunning || (isRunning && startedAt != nil))

        if !isRunning,
           let newMeasurement = newMeasurementOnStop() {
            saveMeasurement(newMeasurement)
            clear()
        }

        if isRunning {
            beginTick()
        }
    }

    func onDelete(measurement: Measurement) -> Void {
        do {
            delete(measurement: measurement)
            try save()

            withAnimation {
                lastRemoved = measurement
            }
        } catch {
//            model.alertDisplay = model.alertDisplay
//                .weakWritten(title: "Error", message: "Failed to delete measurement: \(error.localizedDescription)")
        }
    }

    func restoreRemoved(_  measurement: Measurement) {
        do {
//            modelContext.insert(measurement)
//            try modelContext.save()

            withAnimation {
                lastRemoved = nil
            }
        } catch {
//            model.alertDisplay = model.alertDisplay
//                .weakWritten(
//                    title: "Error",
//                    message: "Failed to restore measurement: \(error.localizedDescription)"
//                )
        }
    }


    func save() throws {
//        try modelContext.save()
    }

    func saveMeasurement(_ measurement: Measurement) {
        do {
//            _ = try Tima.Task.findOrCreate(
//                name: measurement.taskName,
//                in: modelContext
//            )
//
//            modelContext.insert(measurement)
//
//            try modelContext.save()
        } catch {
//            model.alertDisplay = model.alertDisplay
//                .weakWritten(title: "Error", message: "Failed to create measurement, or task: \(error)")
        }
    }

    func delete(measurement: Measurement) {
//        modelContext.delete(measurement)
    }

    func begin(taskName: String, work: String) {
        self.taskName = taskName
        self.work = work
        isRunning = true
        startedAt = Date()
        endedAt = nil
        elapsedSeconds = ""
    }

    func clear() {
        taskName = ""
        work = ""
        elapsedSeconds = ""
    }

    func newMeasurementOnStop() -> Measurement? {
        if let startedAt,
           let endedAt {
            return Measurement(
                taskName: taskName,
                work: work,
                start: startedAt,
                end: endedAt
            )
        }
        return nil
    }

    func newMeasurementOnResume() -> Measurement? {
        if let startedAt {
            return Measurement(
                taskName: taskName,
                work: work,
                start: startedAt,
                end: Date()
            )
        }
        return nil
    }

    func beginTick() {
        startedAt = Date()
        timer?.invalidate()
        timer = nil

        let newTimer = Timer(timeInterval: 0.01, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tick()
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func tick() {
        if let startedAt = startedAt {
            let duration = Date().timeIntervalSince(startedAt)
            elapsedSeconds = "\(duration)"
        }
        NotificationCenter.default.post(name: .modelContextDidChange, object: nil)
    }
}

