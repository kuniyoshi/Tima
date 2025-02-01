import SwiftUI

// Measurement model for editor
@MainActor
class MeasurementModel: ObservableObject {
    @Published var taskName: String = ""
    @Published var work: String = ""
    @Published var isRunning: Bool = false
    @Published var startedAt: Date?
    @Published var endedAt: Date?
    @Published var alertDisplay = AlertDisplay(error: nil)
    @Published var elapsedSeconds: String = ""
    private var timer: Timer?

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

        let newTimer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tick()
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
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
}
