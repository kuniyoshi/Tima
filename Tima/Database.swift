import SwiftData
import Combine
import Foundation

// Applicatoin wide database.
// This provides all of model which stored.
@MainActor
final class Database: ObservableObject {
    private static func mapToGroupedMeasurements(from measurements: [Measurement], with tasks: [Tima.Task]) -> [[(Measurement, Tima.Task)]] {
        let dictionary = Dictionary(grouping: measurements, by: { measurement in
            Calendar.current.startOfDay(for: measurement.start)
        })
        let pairs = dictionary.sorted { $0.key > $1.key }
        let groups = pairs.map(\.1)
        return groups.map { values in
            values
                .sorted { $0.start > $1.start }
                .compactMap { item in
                    if let task = tasks.first(where: { $0.name == item.taskName }) {
                        return (item, task)
                    }
                    return nil
                }
        }
    }

    @Published private(set) var measurements: [Measurement] = []
    @Published private(set) var groupedMeasurements: [[(Measurement, Tima.Task)]] = []
    @Published private(set) var tasks: [Tima.Task] = []

    private var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        Publishers.CombineLatest($measurements, $tasks)
            .map { measurements, tasks in
                Database.mapToGroupedMeasurements(from: measurements, with: tasks)
            }
            .sink { [unowned self] newValue in
                self.groupedMeasurements = newValue
            }
            .store(in: &cancellables)

        load() // TODO: move out of init
    }

    func load() {
        fetchMeasurements()
        fetchTasks()
    }

    func addMeasurement(_ item: Measurement) {
        modelContext.insert(item)
        measurements = (measurements + [item]).sorted { $0.start > $1.start }
    }

    func addTask(_ item: Tima.Task) {
        modelContext.insert(item)
        tasks.append(item)
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
            let request = FetchDescriptor<Tima.Task>()
            tasks = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }
}

