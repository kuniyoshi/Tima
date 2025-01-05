import SwiftUI
import SwiftData
import UserNotifications
import AVFoundation

struct TimeBoxView: View {
    private enum RunningState: String {
        case ready = "hourglass.bottomhalf.filled"
        case running = "hourglass"
        case finished = "hourglass.tophalf.filled"

        func progressed() -> RunningState {
            switch self {
                case .ready: return .running
                case .running: return .finished
                case .finished: return .ready
            }
        }
    }

    private enum QueryType {
        case Auto
        case Button
    }

    private struct Transition {
        var state: RunningState
        var queryType: QueryType
    }

    @Environment(\.modelContext) private var modelContext
    @Query private var timeBoxes: [TimeBox]
    @State private var runningState = RunningState.ready
    @State private var beganAt: Date?
    @State private var endAt: Date?
    @State private var remainingTime: String = "00:00"
    @State private var audioPlayer: AVAudioPlayer? // TODO: 通知にでならせないのかどうか
    @State private var transition: Transition?

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Button(action: onButton) {
                Image(systemName: runningState.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                    .padding()
            }
            .padding([.top, .leading, .trailing])
            .keyboardShortcut(" ", modifiers: [])

            HStack {
                if runningState != .ready {
                    Text("Remain")
                    Text(remainingTime).monospacedDigit()
                }
            }
            .onReceive(timer) { _ in
                onTick()
            }

            HStack {
                Spacer()

                TimeBoxCountView(spans: makeSpans(timeBoxes))
                    .padding()

                Spacer()
            }

            TimeBoxListView(makeCounts(timeBoxes))
        }
        .onAppear {
            requestNotificationPermission()
        }
        .toolbar {
            ToolbarItem {
                switch runningState {
                    case .ready:
                        EmptyView()
                    case .running:
                        Image(systemName: "alarm")
                            .padding()
                    case .finished:
                        EmptyView()
                }
            }
        }
    }

    private func makeCounts(_ timeBoxes: [TimeBox]) -> [(String, Int)] {
        let map = Dictionary(grouping: timeBoxes) { timeBox in
            Calendar.current.startOfDay(for: timeBox.start)
        }
        let keys = map.keys.sorted(by: <)
        return keys.map { key in
            let date = DateFormatter.localizedString(
                from: key,
                dateStyle: .medium,
                timeStyle: .none
            )
            return (date, map[key]?.count ?? 00)
        }
    }

    private func makeSpans(_ timeBoxes: [TimeBox]) -> [(Int, Int)] {
        let from = Calendar.current.startOfDay(for: Date())
        let list = timeBoxes.filter { $0.start >= from }
        return list.map { timeBox in
            let minutes = Int(timeBox.start.timeIntervalSince(from)) / 60
            return (minutes, timeBox.workMinutes)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound]) { granted, error in
                print("Notification permission: \(granted)")
                if let error {
                    print("Could not request notification permission: \(error.localizedDescription)")
                }
            }
    }

    private func onButton() {
        transition = Transition(
            state: runningState.progressed(),
            queryType: .Button
        )
    }

    private func onTick() {
        if let transition {
            runningState = transition.state

            switch transition.queryType {
                case .Auto:
                    switch transition.state {
                        case .ready:
                            playSe(fileName: "rest_end", fileType: "mp3")
                            notify(content: endRestNotification())
                        case .running:
                            assert(false, "Should not be running automatically")
                        case .finished:
                            playSe(fileName: "time_box_end", fileType: "mp3")
                            notify(content: endWorkNotification())
                    }
                case .Button:
                    switch transition.state {
                        case .ready:
                            break
                        case .running:
                            playSe(fileName: "time_box_begin", fileType: "mp3")
                        case .finished:
                            break
                    }
            }

            switch transition.state {
                case .ready:
                    beganAt = nil
                    endAt = nil
                case .running:
                    beganAt = Date()
                case .finished:
                    endAt = Date()
                    if let beganAt {
                        pushTimeBoxData(beganAt)
                    } else {
                        print("No beganAt found")
                    }
            }

            self.transition = nil
        }

        switch runningState {
            case .ready:
                break
            case .running:
                tickWhileRunning()
            case .finished:
                tickWhileFinished()
        }
    }

    private func tickWhileFinished() {
        assert(endAt != nil)

        guard let endAt else {
            return
        }

        let now = Date()
        let elapsedTime = now.timeIntervalSince(endAt)
        let remain = max(
            UserDefaults.standard.integer(forKey: SettingsKeys.TimeBox.breakMinutes.rawValue)
            * 60 - Int(elapsedTime),
            0
        )
        let minutes = Int(remain) / 60
        let seconds = Int(remain) % 60

        remainingTime = String(format: "%02d:%02d", minutes, seconds)

        if remain == 0 {
            transition = Transition(
                state: runningState.progressed(),
                queryType: .Auto
            )
        }
    }

    private func tickWhileRunning() {
        assert(beganAt != nil)

        guard let beganAt else {
            return
        }

        let now = Date()
        let elapsedTime = now.timeIntervalSince(beganAt)
        let remain = max(
            UserDefaults.standard.integer(forKey: SettingsKeys.TimeBox.workMinutes.rawValue)
            * 60 - Int(elapsedTime),
            0
        )
        let minutes = Int(remain) / 60
        let seconds = Int(remain) % 60

        remainingTime = String(format: "%02d:%02d", minutes, seconds)

        if remain == 0 {
            transition = Transition(
                state: runningState.progressed(),
                queryType: .Auto
            )
        }
    }

    private func endRestNotification() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time to Focus"
        content.body = "Break is over.  It's time to focus and get back to work!"
        content.sound = nil
        return content
    }

    private func endWorkNotification() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time's up!"
        content.body = "TimeBox finished!  Good work!"
        content.sound = nil
        return content
    }

    private func notify(content: UNMutableNotificationContent) {
        if (!UserDefaults.standard.bool(forKey: SettingsKeys.TimeBox.isBannerNotification.rawValue)) {
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Could not schedule notification: \(error.localizedDescription)")
            }
        }
    }

    func pushTimeBoxData(_ beganAt: Date) {
        let durationMinutes = UserDefaults.standard.integer(forKey: SettingsKeys.TimeBox.workMinutes.rawValue)
        let adjustedDuration = TimeInterval(durationMinutes * 60) * 0.9

        if (Date().timeIntervalSince(beganAt) < adjustedDuration) {
            return
        }

        let timeBoxData = TimeBox(start: beganAt, workMinutes: durationMinutes)

        modelContext.insert(timeBoxData)
    }

    func playSe(fileName: String, fileType: String = "wav") {
        if (!UserDefaults.standard.bool(forKey: SettingsKeys.TimeBox.isSoundNotification.rawValue)) {
            return
        }

        // TODO: 通知のサウンドをカスタムする?

        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Could not find \(fileName).\(fileType)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not play(\(fileName).\(fileType)): \(error.localizedDescription)")
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: TimeBox.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    context.insert(TimeBox(start: Date(), workMinutes: 25))

    return TimeBoxView()
        .modelContainer(container)
}
