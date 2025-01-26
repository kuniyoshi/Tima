import SwiftUI

// Measurement model for editor
class MeasurementModel: ObservableObject {
    @Published var taskName: String = ""
    @Published var work: String = ""
    @Published var isRunning: Bool = false
    @Published var startedAt: Date?
    @Published var endedAt: Date?
    @Published var alertDisplay = AlertDisplay(error: nil)
    @Published var elapsedSeconds: String = ""

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
}
