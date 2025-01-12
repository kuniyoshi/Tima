import SwiftUI

class MeasurementModel: ObservableObject {
    @Published var taskName: String = ""
    @Published var work: String = ""
    @Published var isRunning: Bool = false
    @Published var startedAt: Date?
    @Published var endedAt: Date?
    @Published var alertDisplay = AlertDisplay(error: nil)
    @Published var elapsedSeconds: String = ""
}
