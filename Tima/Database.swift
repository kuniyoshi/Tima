import SwiftUI
import SwiftData
import Combine
import Foundation

// Applicatoin wide database.
// This provides all of model which stored.
@MainActor
final class Database: ObservableObject {
    private static func mapToGroupedMeasurements(from measurements: [Measurement], with works: [Work]) -> [[(Measurement, Work)]] {
        let dictionary = Dictionary(grouping: measurements, by: { measurement in
            Calendar.current.startOfDay(for: measurement.start)
        })
        let pairs = dictionary.sorted { $0.key > $1.key }
        let groups = pairs.map(\.1)
        return groups.map { values in
            values
                .sorted { $0.start > $1.start }
                .compactMap { item in
                    if let work = works.first(where: { $0.name == item.work }) {
                        return (item, work)
                    }
                    return nil
                }
        }
    }

    private static func mapToMeasurementSpans(from measurements: [Measurement], with works: [Work]) -> [(Int, Int, SwiftUI.Color)] {
        let from = Calendar.current.startOfDay(for: Date())
        return measurements.filter { $0.start >= from }
            .map { measurement in
                let minutes = Int(measurement.start.timeIntervalSince(from)) / 60
                let duration = Int(measurement.duration) / 60
                let color = works.first(where: { $0.name == measurement.work })?.color.uiColor ?? .black
                return (minutes, duration, color)
            }
    }

    @Published private(set) var measurements: [Measurement] = []
    @Published private(set) var groupedMeasurements: [[(Measurement, Work)]] = []
    @Published private(set) var measurementSpans: [(Int, Int, SwiftUI.Color)] = [] // TODO: use specific structure
    @Published private(set) var works: [Work] = []
    @Published private(set) var timeBoxes: [TimeBox] = []

    private var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        Publishers.CombineLatest($measurements, $works)
            .map { measurements, works in
                Self.mapToGroupedMeasurements(from: measurements, with: works)
            }
            .sink { [unowned self] newValue in
                self.groupedMeasurements = newValue
            }
            .store(in: &cancellables)

        Publishers.CombineLatest($measurements, $works)
            .map { measurements, works in
                Self.mapToMeasurementSpans(from: measurements, with: works)
            }
            .sink { [unowned self] newValue in
                self.measurementSpans = newValue
            }
            .store(in: &cancellables)

        load() // TODO: move out of init
    }

    func load() {
        fetchMeasurements()
        fetchTasks()
        fetchTimeBoxes()
    }

    func addTask(_ item: Work) {
        modelContext.insert(item)
        works.append(item)
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
        // keep task against addMeasurement add to tasks
        modelContext.delete(measurement)
        try modelContext.save()
        measurements.removeAll { $0.id == measurement.id }
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

    private func fetchTasks() {
        do {
            let request = FetchDescriptor<Work>()
            works = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
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

    private func findOrCreateWork(name: String) throws -> Work {
        let request = FetchDescriptor<Work>(
            predicate: #Predicate {
                $0.name == name
            }
        )

        let results = try modelContext.fetch(request)
        assert(results.count <= 1)

        if let existing = results.first {
            return existing
        } else {
            let newWork = Work(name: name, color: .random)
            modelContext.insert(newWork)
            works = (works + [newWork])
            return newWork
        }
    }
}

