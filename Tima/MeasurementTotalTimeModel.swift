import SwiftUI

@MainActor
class MeasurementTotalTimeModel: ObservableObject {
    @Published private(set) var totalMinutes: Int

    init(totalMinutes: Int = 0) {
        self.totalMinutes = totalMinutes
    }

    func setValue(_ value: Int) {
        totalMinutes = value
    }
}
