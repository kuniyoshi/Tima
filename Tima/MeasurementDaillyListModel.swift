import SwiftUI
import Combine

class MeasurementDaillyListModel: ObservableObject, Identifiable {
    @Published var pairs: [(MeasurementItemModel, Work)]

    private let onPlay: PassthroughSubject<Measurement, Never>
    private let onDelete: PassthroughSubject<Measurement, Never>
    private var cancellables: Set<AnyCancellable>

    init(
        pairs: [(MeasurementItemModel, Work)],
        onPlay: @escaping (Measurement) -> Void,
        onDelete: @escaping (Measurement) -> Void
    ) {
        self.pairs = pairs
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
        pairs.first?.0.measurement.id.hashValue ?? 0
    }

    var head: Measurement? {
        pairs.first?.0.measurement
    }

    func playMeasurement(_ measurement: Measurement) {
        self.onPlay.send(measurement)
    }

    func removeMeasurement(_ measurement: Measurement) {
        self.pairs.removeAll { $0.0.measurement.id == measurement.id }
        self.onDelete.send(measurement)
    }
}
