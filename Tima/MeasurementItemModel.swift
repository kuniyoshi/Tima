import SwiftUI

class MeasurementItemModel: ObservableObject {
    @Published private(set) var measurement: Measurement
    @Environment(\.modelContext) private var context

    init(measurement: Measurement) {
        _measurement = .init(wrappedValue: measurement)
    }
}
