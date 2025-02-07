import SwiftUI
import SwiftData
import Combine

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
    @Published var spans: [(Int, Int, SwiftUI.Color)] = []

    private let database: Database
    private var cancellables = Set<AnyCancellable>()

    init(database: Database) {
        self.database = database

        database.$measurementSpans
            .receive(on: DispatchQueue.main)
            .assign(to: &$spans)
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
