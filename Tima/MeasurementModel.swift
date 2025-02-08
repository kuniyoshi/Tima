import SwiftUI

// Measurement model for editor
@MainActor
class MeasurementModel: ObservableObject {
    private enum Transaction {
        case begin
        case stop
        case resume(taskName: String, work: String)
    }

    @Published var taskName: String = ""
    @Published var work: String = ""
    @Published var isRunning: Bool = false
    @Published var startedAt: Date?
    @Published var endedAt: Date?
    @Published var alertDisplay = AlertDisplay(error: nil)
    @Published var elapsedSeconds: String = ""
    @Published var spans: [(Int, Int, SwiftUI.Color)] = []
    @Published var measurements: [Measurement] = []
    @Published var dailyListModels: [MeasurementDaillyListModel] = []
    var lastRemoved: Measurement?
    private var timer: Timer?
    private let database: Database

    init(database: Database) {
        self.database = database

        database.$measurementSpans
            .receive(on: DispatchQueue.main)
            .assign(to: &$spans)
        database.$measurements
            .receive(on: DispatchQueue.main)
            .assign(to: &$measurements)
        database.$groupedMeasurements
            .map { groupedMeasurements in
                groupedMeasurements.compactMap { pairs in
                    QuxModel.createModel(
                        items: pairs,
                        onPlay: { [weak self] measurement in
                            self?.processTransaction(transaction: .resume(taskName: measurement.taskName, work: measurement.work))
                        },
                        onDelete: { [weak self] measurement in
                            self?.delete(measurement: measurement)
                        })
                }
            }
            .assign(to: &$dailyListModels)
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

    func delete(measurement: Measurement) {
        do {
            try database.deleteMeasurement(measurement)
            lastRemoved = measurement
        } catch {
            alertDisplay = alertDisplay
                .weakWritten(title: "Error", message: "Failed to delete measurement: \(error.localizedDescription)")
        }
    }

    func restoreRemoved(measurement: Measurement) {
        do {
            try database.addMeasurement(measurement)
            lastRemoved = nil
        } catch {
            alertDisplay = alertDisplay
                .weakWritten(
                    title: "Error",
                    message: "Failed to restore measurement: \(error.localizedDescription)"
                )
        }
    }

    func save(measurement: Measurement) {
        do {
            try database.addMeasurement(measurement)
        } catch {
            alertDisplay = alertDisplay
                .weakWritten(title: "Error", message: "Failed to create measurement, or task: \(error)")
        }
    }

    func tick() {
        if let startedAt = startedAt {
            let duration = Int(Date().timeIntervalSince(startedAt))
            let minutes = duration / 60
            let seconds = duration % 60
            if minutes > 0 {
                elapsedSeconds = String(format: "%d:%02d", minutes, seconds)
            } else {
                elapsedSeconds = "\(seconds)"
            }
        }
    }

    func toggleRunning() {
        if isRunning {
            processTransaction(transaction: .stop)
        } else {
            processTransaction(transaction: .begin)
        }
    }

    private func processTransaction(transaction: Transaction) {
        switch transaction {
            case .begin:
                isRunning = true
            case .stop:
                isRunning = false
            case .resume(let taskName, let work):
                if isRunning,
                   let newMeasurement = newMeasurementOnResume() {
                    save(measurement: newMeasurement)
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
            save(measurement: newMeasurement)
            clear()
        }

        if isRunning {
            beginTick()
        }
    }
}
