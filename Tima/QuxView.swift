import SwiftUI
import SwiftData

struct QuxView: View {
    @StateObject private var model: QuxModel

    var body: some View {
        VStack {
            Text(model.elapsedSeconds)
                .padding()

            ScrollViewReader { proxy in
                List {
                    HStack {
                        Spacer()
                        if let lastRemoved = model.lastRemoved {
                            Button(action: {
                                model.restoreRemoved(lastRemoved)
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                            }
                            .transition(.slide.combined(with: .opacity))
                        }
                    }

                    ForEach(model.dailyListModels, id: \.self.id) { listModel in
                        MeasurementDailyListView(model: listModel)
                    }
                }
                .onChange(of: model.measurements) { _, newMeasurements in
                    if let lastMeasurement = newMeasurements.last {
                        proxy.scrollTo(lastMeasurement.id, anchor: .top)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        }
        .onAppear {
            model.beginTick()
        }
    }

    init(model: QuxModel) {
        _model = .init(wrappedValue: model)
    }
}

@MainActor
class QuxModel: ObservableObject {
    enum Transaction {
        case begin
        case stop
        case resume(taskName: String, work: String)
    }

    // LiveData的な仕組みとして @Query を使用する
    @Query(sort: \Measurement.start, order: .reverse) var measurements: [Measurement]
    @Query var tasks: [Tima.Task]

    @Published var isRunning: Bool = false
    @Published var taskName: String = ""
    @Published var work: String = ""
    @Published var startedAt: Date?
    @Published var endedAt: Date?
    @Published var elapsedSeconds: String = ""
    private let modelContext: ModelContext
    private var timer: Timer?
    @State var lastRemoved: Measurement?

    // measurements と tasks の変更に応じて毎日ごとのモデルを生成する
    var dailyListModels: [MeasurementDaillyListModel] {
        let grouped = createGroupedMeasurements(measurements)
        return grouped.map { items in
            let pairs: [(Measurement, Tima.Task)] = items.compactMap { item in
                if let task = tasks.first(where: { $0.name == item.taskName }) {
                    return (item, task)
                }
                return nil
            }
            return MeasurementDaillyListModel(
                pairs: pairs,
                onPlay: { [weak self] measurement in
                    self?.processTransaction(transaction: .resume(taskName: measurement.taskName, work: measurement.work))
                },
                onDelete: { [weak self] measurement in
                    self?.onDelete(measurement: measurement)
                }
            )
        }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // @Query で自動更新されるので、手動の fetchData() は不要になるわ
    }

    // これ以降の保存・削除などのメソッドは、modelContext への操作を行えば @Query が反映してくれる仕組みになっているのよ

    func processTransaction(transaction: Transaction) {
        switch transaction {
            case .begin:
                isRunning = true
            case .stop:
                isRunning = false
            case .resume(let taskName, let work):
                if isRunning, let newMeasurement = newMeasurementOnResume() {
                    saveMeasurement(newMeasurement)
                }
                begin(taskName: taskName, work: work)
        }

        if isRunning {
            startedAt = Date()
        } else {
            endedAt = Date()
        }

        assert(!isRunning || (isRunning && startedAt != nil))

        if !isRunning, let newMeasurement = newMeasurementOnStop() {
            saveMeasurement(newMeasurement)
            clear()
        }

        if isRunning {
            beginTick()
        }
    }

    func onDelete(measurement: Measurement) {
        do {
            delete(measurement: measurement)
            try save()

            withAnimation {
                lastRemoved = measurement
            }
        } catch {
            // エラー処理は必要に応じて実装してね
        }
    }

    func restoreRemoved(_ measurement: Measurement) {
        do {
            modelContext.insert(measurement)
            try modelContext.save()

            withAnimation {
                lastRemoved = nil
            }
        } catch {
            // エラー処理は必要に応じて実装してね
        }
    }

    func save() throws {
        try modelContext.save()
    }

    func saveMeasurement(_ measurement: Measurement) {
        do {
            _ = try Tima.Task.findOrCreate(
                name: measurement.taskName,
                in: modelContext
            )

            modelContext.insert(measurement)
            try modelContext.save()
        } catch {
            // エラー処理は必要に応じて実装してね
        }
    }

    func delete(measurement: Measurement) {
        modelContext.delete(measurement)
    }

    private func createGroupedMeasurements(_ measurements: [Measurement]) -> [[Measurement]] {
        // 日付ごとにグループ化する処理
        let grouped = Dictionary(grouping: measurements) { measurement in
            Util.date(measurement.start)
        }
        return grouped.keys.sorted(by: >).map { key in
            grouped[key] ?? []
        }
    }

    func begin(taskName: String, work: String) {
        self.taskName = taskName
        self.work = work
        isRunning = true
        startedAt = Date()
        endedAt = nil
        elapsedSeconds = ""
    }

    func clear() {
        taskName = ""
        work = ""
        elapsedSeconds = ""
    }

    func newMeasurementOnStop() -> Measurement? {
        if let startedAt, let endedAt {
            return Measurement(
                taskName: taskName,
                work: work,
                start: startedAt,
                end: endedAt
            )
        }
        return nil
    }

    func newMeasurementOnResume() -> Measurement? {
        if let startedAt {
            return Measurement(
                taskName: taskName,
                work: work,
                start: startedAt,
                end: Date()
            )
        }
        return nil
    }

    func beginTick() {
        startedAt = Date()
        timer?.invalidate()
        timer = nil

        let newTimer = Timer(timeInterval: 0.01, repeats: true) { [weak self] _ in
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
