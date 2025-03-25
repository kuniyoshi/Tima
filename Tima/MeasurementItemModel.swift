import SwiftUI

// Updates measurement by view's query
class MeasurementItemModel: ObservableObject {
    @Published private(set) var measurement: Measurement
    @Published private(set) var color: Color
    private let onUpdate: (Measurement) -> Void

    init(_ measurement: Measurement,
         color: Color,
         onUpdate: @escaping (Measurement) -> Void) {
        _measurement = .init(wrappedValue: measurement)
        self.onUpdate = onUpdate
        self.color = color
    }

    func updateDetail(_ detail: String) {
        measurement.detail = detail
        self.onUpdate(measurement)
    }

    func updateEndDate(_ endDate: Date) {
        measurement.end = endDate
        self.onUpdate(measurement)
    }

    func updateStartDate(_ startDate: Date) {
        measurement.start = startDate
        self.onUpdate(measurement)
    }
}
