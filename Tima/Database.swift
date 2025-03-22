import SwiftUI
import SwiftData
import Combine
import Foundation

// Applicatoin wide database.
// This provides all of model which stored.
@MainActor
final class Database: ObservableObject {
    private static func mapToGroupedMeasurements(from measurements: [Measurement],
                                                 with imageColors: [ImageColor]) -> [[(Measurement, ImageColor)]] {
        let dictionary = Dictionary(grouping: measurements, by: { measurement in
            Calendar.current.startOfDay(for: measurement.start)
        })
        let pairs = dictionary.sorted { $0.key > $1.key }
        let groups = pairs.map(\.1)
        return groups.map { values in
            values
                .sorted { $0.start > $1.start }
                .compactMap { item in
                    if let work = imageColors.first(where: { $0.name == item.work }) {
                        return (item, work)
                    }
                    return nil
                }
        }
    }

    private static func mapToMeasurementSpans(from measurements: [Measurement],
                                              with imageColors: [ImageColor]) -> [(Int, Int, Color)] {
        let from = Calendar.current.startOfDay(for: Date())
        return measurements.filter { $0.start >= from }
            .map { measurement in
                let minutes = Int(measurement.start.timeIntervalSince(from)) / 60
                let duration = Int(measurement.duration) / 60
                let color = imageColors.first(where: { $0.name == measurement.work })?.color.uiColor ?? .black
                return (minutes, duration, color)
            }
    }

    @Published private(set) var measurements: [Measurement] = []
    @Published private(set) var groupedMeasurements: [[(Measurement, ImageColor)]] = []
    @Published private(set) var measurementSpans: [(Int, Int, Color)] = [] // TODO: use specific structure
    @Published private(set) var imageColors: [ImageColor] = []
    @Published private(set) var timeBoxes: [TimeBox] = []

    private var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()

    init(modelContext: ModelContext, onRefreshDate: AnyPublisher<Void, Never>) {
        self.modelContext = modelContext

        Publishers.CombineLatest($measurements, $imageColors)
            .map { measurements, imageColors in
                Self.mapToGroupedMeasurements(from: measurements, with: imageColors)
            }
            .sink { [unowned self] newValue in
                self.groupedMeasurements = newValue
            }
            .store(in: &cancellables)

        Publishers.CombineLatest($measurements, $imageColors)
            .map { measurements, imageColors in
                Self.mapToMeasurementSpans(from: measurements, with: imageColors)
            }
            .sink { [unowned self] newValue in
                self.measurementSpans = newValue
            }
            .store(in: &cancellables)

        onRefreshDate.sink { [weak self] in
            guard let self else { return }
            self.groupedMeasurements = Self.mapToGroupedMeasurements(from: self.measurements, with: self.imageColors)
            self.measurementSpans = Self.mapToMeasurementSpans(from: self.measurements, with: self.imageColors)
        }
        .store(in: &cancellables)

        load() // TODO: move out of init
    }

    func load() {
        fetchMeasurements()
        fetchImageColors()
        fetchTimeBoxes()
    }

    func addImageColor(_ item: ImageColor) {
        modelContext.insert(item)
        imageColors.append(item)
    }

    func addMeasurement(_ measurement: Measurement) throws {
        _ = try findOrCreateWork(name: measurement.work)

        modelContext.insert(measurement)

        try modelContext.save()

        measurements = (measurements + [measurement])
            .sorted { $0.start > $1.start }
    }

    func addTimeBox(_ timeBox: TimeBox) {
        do {
            modelContext.insert(timeBox)
            try modelContext.save()

            timeBoxes = (timeBoxes + [timeBox])
        } catch {
            print("Could not save time box: \(error)")
        }
    }

    func deleteMeasurement(_ measurement: Measurement) throws {
        // keep imageColor against addMeasurement add to imageColor
        modelContext.delete(measurement)
        try modelContext.save()
        measurements.removeAll { $0.id == measurement.id }
    }

    func hasMeasurement(_ measurement: Measurement) -> Bool {
        return measurements.contains(where: { $0.id == measurement.id })
    }

    func updateMeasurement(_ measurement: Measurement) throws {
        guard let index = measurements.firstIndex(where: { $0.id == measurement.id} ) else {
            throw NSError(
                domain: "Database error",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Measurement not found"]
            )
        }

        try modelContext.save()
        measurements[index] = measurement
        measurements.sort { $0.start > $1.start }
    }

    private func fetchMeasurements() {
        do {
            let request = FetchDescriptor<Measurement>(
                predicate: nil,
                sortBy: [SortDescriptor(\.start, order: .reverse)]
            )
            measurements = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch measurements: \(error)")
        }
    }

    private func fetchImageColors() {
        do {
            let request = FetchDescriptor<ImageColor>()
            imageColors = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch imageColors: \(error)")
        }
    }

    private func fetchTimeBoxes() {
        do {
            let request = FetchDescriptor<TimeBox>()
            timeBoxes = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch time boxes: \(error)")
        }
    }

    private func findOrCreateWork(name: String) throws -> ImageColor {
        let request = FetchDescriptor<ImageColor>(
            predicate: #Predicate {
                $0.name == name
            }
        )

        let results = try modelContext.fetch(request)
        assert(results.count <= 1)

        if let existing = results.first {
            return existing
        } else {
            let newWork = ImageColor(name: name, color: .random)
            modelContext.insert(newWork)
            imageColors = (imageColors + [newWork])
            return newWork
        }
    }
}

