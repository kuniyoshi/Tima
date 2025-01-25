import SwiftUI
import Combine

class MeasurementDaillyListModel: ObservableObject, Identifiable {
    @Published var measurements: [Measurement]

    private let onPlay: PassthroughSubject<Measurement, Never>
    private let onDelete: PassthroughSubject<Measurement, Never>
    private var cancellables: Set<AnyCancellable>

    init(
        measurements: [Measurement],
        onPlay: @escaping (Measurement) -> Void,
        onDelete: @escaping (Measurement) -> Void
    ) {
        self.measurements = measurements
        self.onPlay = PassthroughSubject()
        self.onDelete = PassthroughSubject()
        cancellables = []

        self.onPlay.sink { measurement in
            onPlay(measurement)
        }
        .store(in: &cancellables)
        self.onDelete.sink { measurement in
            onDelete(measurement)
        }
        .store(in: &cancellables)
    }

    var id: Int {
        measurements.first?.id.hashValue ?? 0
    }

    var head: Measurement? {
        measurements.first
    }

    func playMeasurement(_ measurement: Measurement) {
        self.onPlay.send(measurement)
    }

    func removeMeasurement(_ measurement: Measurement) {
        self.measurements.removeAll { $0.id == measurement.id }
        self.onDelete.send(measurement)
    }
}
