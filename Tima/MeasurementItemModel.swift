import SwiftUI

class MeasurementItemModel: ObservableObject {
    @Published private(set) var measurement: Measurement
    @Environment(\.modelContext) private var context

    init(measurement: Measurement) {
        _measurement = .init(wrappedValue: measurement)
    }

    func updateDetail(_ detail: String) {
        context.update {
            measurement.detail = detail // TODO: need trim by robust way
        }
    }

    func updateEndDate(_ endDate: Date) {
        context.update {
            measurement.end = endDate
        }
    }

    func updateStartDate(_ startDate: Date) {
        context.update {
            measurement.start = startDate
        }
    }
}
