import SwiftData
import Combine
import Foundation

@MainActor
final class Database: ObservableObject {
    static let shared = Database()

    @Published private(set) var measurements: [Measurement] = []
    @Published private(set) var groupedMeasurements: [[Measurement]] = []
    @Published private(set) var tasks: [Tima.Task] = []

    private var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()

    private init() {
        do {
            let schema = Schema([
                Tima.Task.self,
                Measurement.self,
                TimeBox.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = container.mainContext

            $measurements.map { measurements in
                let dictionary = Dictionary(grouping: measurements, by: { measurement in
                    Calendar.current.startOfDay(for: measurement.start)
                })

                return dictionary
                    .sorted { $0.key > $1.key }
                    .map { $0.value.sorted { $0.start > $1.start } }
            }
            .sink { [unowned self] newValue in
                self.groupedMeasurements = newValue
            }
            .store(in: &cancellables)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    func addMeasurement(_ item: Measurement) {
        modelContext.insert(item)
        measurements = (measurements + [item]).sorted { $0.start > $1.start }
    }

    func addTask(_ item: Tima.Task) {
        modelContext.insert(item)
        tasks.append(item)
    }

    private func featchMeasurements() {
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

    private func featchTasks() {
        do {
            let request = FetchDescriptor<Tima.Task>()
            tasks = try modelContext.fetch(request)
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }
}

