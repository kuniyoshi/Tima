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

    struct MeasurementState { // TODO: rename
        var work: String
        var detail: String
        private(set) var isRunning: Bool
        private(set) var startedAt: Date?
        private(set) var endedAt: Date?
        private(set) var database: Database

        func assuredForBegin() -> Self {
            .init(
                work: work,
                detail: detail,
                isRunning: true,
                startedAt: Date(),
                endedAt: nil,
                database: database
            )
        }

        func begined(work: String, detail: String) -> Self {
            .init(
                work: work,
                detail: detail,
                isRunning: true,
                startedAt: Date(),
                endedAt: nil,
                database: database
            )
        }

        func cleared() -> Self {
            .init(
                work: work,
                detail: detail,
                isRunning: false,
                startedAt: nil,
                endedAt: nil,
                database: database
            )
        }

        func edited(startedAt: Date) -> Self {
            .init(
                work: work,
                detail: detail,
                isRunning: isRunning,
                startedAt: startedAt,
                endedAt: endedAt,
                database: database
            )
        }

        func stopped() -> Self {
            .init(
                work: work,
                detail: detail,
                isRunning: false,
                startedAt: startedAt,
                endedAt: Date(),
                database: database
            )
        }
    }

    private struct CurrentMeasurement {
        private(set) var value: Measurement?

        func fromBufferForStop(_ buffer: MeasurementState) -> Self {
            if let startedAt = buffer.startedAt,
               let endedAt = buffer.endedAt {
                .init(value: .init(
                    work: buffer.work,
                    detail: buffer.detail,
                    start: startedAt,
                    end: endedAt
                ))
            } else {
                .init(value: nil)
            }
        }

        func fromBufferOnResume(_ buffer: MeasurementState) -> Self {
            if let startedAt = buffer.startedAt {
                .init(value: .init(
                    work: buffer.work,
                    detail: buffer.detail,
                    start: startedAt,
                    end: Date()
                ))
            } else {
                .init(value: nil)
            }
        }

        func refreshed() -> Self {
            if let value {
                .init(value: .init(work: value.work, detail: value.detail, start: value.start, end: value.end))
            } else {
                .init(value: nil)
            }
        }
    }

    @Published var state: MeasurementState
    @Published private(set) var alertDisplay = AlertDisplay(error: nil)
    @Published private(set) var elapsedSeconds: String = "" // TODO: move to struct
    @Published private(set) var spans: [(Int, Int, Color)] = []
    @Published private(set) var measurements: [Measurement] = []
    @Published private(set) var dailyListModels: [MeasurementDaillyListModel] = []
    @Published private(set) var totalTimeModel: MeasurementTotalTimeModel
    private(set) var lastRemoved: Measurement?
    private var timer: Timer?
    private let database: Database
    private var cancellables: Set<AnyCancellable> = []
    private var current: CurrentMeasurement

    init(database: Database, onTerminate: AnyPublisher<Void, Never>) {
        self.database = database
        totalTimeModel = .init()
        state = .init(
            work: "",
            detail: "",
            isRunning: false,
            startedAt: nil,
            endedAt: nil,
            database: database
        )
        current = .init(value: nil)

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

        onTerminate.sink { [weak self] in
            guard let self else { return }
            if !self.state.isRunning {
                return
            }
            self.processTransaction(transaction: .stop)
        }
        .store(in: &cancellables)

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

    func delete(measurement: Measurement) {
        do {
            try database.deleteMeasurement(measurement)
            lastRemoved = measurement
        } catch {
            alertDisplay = alertDisplay
                .weakWritten(title: "Error", message: "Failed to delete measurement: \(error.localizedDescription)")
        }
    }

    func dismissAlert() {
        alertDisplay = alertDisplay.cleared()
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

    func toggleRunning() {
        if state.isRunning {
            processTransaction(transaction: .stop)
        } else {
            processTransaction(transaction: .begin)
        }
    }

    func updateStartedAt(_ startedAt: Date) {
        state = state.edited(startedAt: startedAt)
    }

    private func beginTick() {
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

    private func onSleep() {
        guard state.isRunning else { return }
        processTransaction(transaction: .stop)
        alertDisplay = alertDisplay.weakWritten(title: "Auto stop", message: "You may fogot stop measurement.")
    }

    private func processTransaction(transaction: Transaction) {
        switch transaction {
            case .begin:
                state = state.assuredForBegin()
                elapsedSeconds = ""
            case .stop:
                state = state.stopped()
                current = current.fromBufferForStop(state)
                if let newMeasurement = current.value {
                    save(measurement: newMeasurement)
                }
                state = state.cleared()
                elapsedSeconds = ""
            case .resume(let work, let detail):
                current = current.fromBufferOnResume(state)
                if let newMeasurement = current.value {
                    save(measurement: newMeasurement)
                }
                state = state.begined(work: work, detail: detail)
                elapsedSeconds = ""
        }

        if state.isRunning {
            beginTick()
        }
    }

    private func save(measurement: Measurement) {
        do {
            try database.addMeasurement(measurement)
        } catch {
            alertDisplay = alertDisplay
                .weakWritten(title: "Error", message: "Failed to create measurement, or imageColor: \(error)")
        }
    }

    private func tick() {
        if let startedAt = state.startedAt {
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
}
