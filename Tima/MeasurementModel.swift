import SwiftUI

class MeasurementModel: ObservableObject {
    @Published var task: Task = Task(name: "task name", color: TimaColor.gray)
    @Published var work: String = ""
    @Published var isRunning: Bool = false
    @Published var startedAt: Date?
    @Published var endedAt: Date?
    @Published var alertDisplay = AlertDisplay(error: nil)
    @Published var elapsedSeconds: String = ""
}
