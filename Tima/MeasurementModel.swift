import AppKit
import SwiftUI
import Combine

// Measurement model for editor
@MainActor
class MeasurementModel: ObservableObject {
    private enum Transaction {
        case begin
        case stop
        case resume(work: String, detail: String)
    }

    @Published var work: String = ""
    @Published var detail: String = ""
    @Published private(set) var isRunning: Bool = false
    @Published var startedAt: Date?
    @Published private(set) var endedAt: Date?
    @Published private(set) var alertDisplay = AlertDisplay(error: nil)
    @Published private(set) var elapsedSeconds: String = ""
    @Published private(set) var spans: [(Int, Int, Color)] = []
    @Published private(set) var measurements: [Measurement] = []
    @Published private(set) var dailyListModels: [MeasurementDaillyListModel] = []
    @Published private(set) var totalTimeModel: MeasurementTotalTimeModel
    private(set) var lastRemoved: Measurement?
    private var timer: Timer?
    private let database: Database
    private var cancellables: Set<AnyCancellable> = []

    init(database: Database) {
        self.database = database
        totalTimeModel = .init()

        database.$measurementSpans
            .receive(on: DispatchQueue.main)
            .assign(to: &$spans)
        database.$measurements
            .receive(on: DispatchQueue.main)
            .assign(to: &$measurements)
        database.$groupedMeasurements
            .map { groupedMeasurements in
                groupedMeasurements.compactMap { pairs in
                    MeasurementDaillyListModel(
                        pairs: pairs.map { (measurement, work) in
                            (MeasurementItemModel(measurement, onUpdate: { measurement in
                                do {
                                    try database.updateMeasurement(measurement)
                                } catch {
                                    print("Could not update measurement: \(error)")
                                }
                            }), work)
                        },
                        onPlay: { [unowned self] measurement in
                            self.processTransaction(transaction: .resume(work: measurement.work, detail: measurement.detail))
                        },
                        onDelete: { [unowned self] measurement in
                            self.delete(measurement: measurement)
                        }
                    )
                }
            }
            .assign(to: &$dailyListModels)

        let center = NSWorkspace.shared.notificationCenter
        center.publisher(for: NSWorkspace.willSleepNotification)
            .sink { [weak self] _ in
                self?.onSleep()
            }
            .store(in: &cancellables)

        $spans.sink { [unowned self] spans in
            totalTimeModel.setValue(spans.map { $0.1 }.reduce(0, +))
        }
        .store(in: &cancellables)
    }

    func begin(work: String, detail: String) {
        self.work = work
        self.detail = detail
        isRunning = true
        startedAt = Date()
        endedAt = nil
        elapsedSeconds = ""
    }

    func clear() {
        startedAt = nil
        endedAt = nil
        work = ""
        detail = ""
        elapsedSeconds = ""
    }

    func dismissAlert() {
        alertDisplay = alertDisplay.cleared()
    }

    func newMeasurementOnStop() -> Measurement? {
        if let startedAt,
           let endedAt {
            return Measurement(
                work: work,
                detail: detail,
                start: startedAt,
                end: endedAt
            )
        }
        return nil
    }

    func newMeasurementOnResume() -> Measurement? {
        if let startedAt {
            return Measurement(
                work: work,
                detail: detail,
                start: startedAt,
                end: Date()
            )
        }
        return nil
    }

    func beginTick() {
        timer?.invalidate()
        timer = nil

        let newTimer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tick()
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer

        elapsedSeconds = ""
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
                .weakWritten(title: "Error", message: "Failed to create measurement, or imageColor: \(error)")
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

            totalTimeModel.setValue(spans.map { $0.1 }.reduce(0, +) + minutes)
        }
    }

    func toggleRunning() {
        if isRunning {
            processTransaction(transaction: .stop)
        } else {
            processTransaction(transaction: .begin)
        }
    }

    private func onSleep() {
        guard isRunning else { return }
        processTransaction(transaction: .stop)
        alertDisplay = alertDisplay.weakWritten(title: "Auto stop", message: "You may fogot stop measurement.")
    }

    private func processTransaction(transaction: Transaction) {
        switch transaction {
            case .begin:
                isRunning = true
            case .stop:
                isRunning = false
            case .resume(let work, let detail):
                if isRunning,
                   let newMeasurement = newMeasurementOnResume() {
                    save(measurement: newMeasurement)
                }
                begin(work: work, detail: detail)
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
