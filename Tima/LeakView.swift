import SwiftUI
import SwiftData

struct LeakView: View {
    @StateObject private var model: LeakModel

    var body: some View {
        VStack {
            Memory24HourHorizontalView(spans: model.spans)
                .padding()

            Text(model.elapsedSeconds)
        }
        .onAppear {
            model.beginTick()
        }
    }

    init(model: LeakModel) {
        _model = .init(wrappedValue: model)
    }

}

@MainActor
class LeakModel: ObservableObject {
    @Published var startedAt: Date?
    @Published var elapsedSeconds: String = ""
    @Published var measurements: [Measurement] = []
    @Published var tasks: [Tima.Task] = []
    private var timer: Timer?
    private let modelContext: ModelContext
    @Published var spans: [(Int, Int, SwiftUI.Color)] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
        spans = makeSpans()
    }

    func makeSpans() -> [(Int, Int, SwiftUI.Color)] {
        let from = Calendar.current.startOfDay(for: Date())
        var spans: [(Int, Int, SwiftUI.Color)] = []
        for i in 0..<measurements.count {
            let m = measurements[i]
            if m.start >= from {
                let minutes = Int(m.start.timeIntervalSince(from)) / 60
                let duration = Int(m.duration) / 60
                spans.append((minutes, duration, .black))
            }
        }
        let list = measurements.filter {
            $0.start >= from
        }
        return list.map { measurement in
            let minutes = Int(measurement.start.timeIntervalSince(from)) / 60
            let duration = Int(measurement.duration) / 60
            return (minutes, duration, .black)
//            if let task = tasks.first(where: { $0.name == measurement.taskName }) {
////                return (minutes, duration, task.color.uiColor)
//                return (minutes, duration, .black)
//            } else {
//                return (minutes, duration, .black)
//            }
        }
    }

    private func fetchData() {
        do {
            let measurementFetchDescriptor = FetchDescriptor<Measurement>()
            let taskFetchDescriptor = FetchDescriptor<Tima.Task>()

            let measurements = try modelContext.fetch(measurementFetchDescriptor)
            let tasks = try modelContext.fetch(taskFetchDescriptor)

            self.measurements = measurements
            self.tasks = tasks
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }

    func beginTick() {
        startedAt = Date()

        timer?.invalidate()
        timer = nil

        let newTimer = Timer(timeInterval: 0.001, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tick()
            }
        }

        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func tick() {
        if let startedAt = startedAt {
            let duration = Date().timeIntervalSince(startedAt)
            elapsedSeconds = "\(duration)"
        }
    }
}
