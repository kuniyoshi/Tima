import SwiftUI
import AVFoundation
import UserNotifications
import Combine

// TimeBox model
@MainActor
class TimeBoxModel: ObservableObject {
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

    @Published private(set) var spans: [(Int, Int)] = []
    @Published private(set) var counts: [(String, Int)] = []
    @Published private(set) var isStateRunning: Bool = false
    @Published private(set) var systemImageName: String = RunningState.ready.rawValue
    @Published private(set) var beganAt: Date?
    @Published private(set) var endAt: Date?
    @Published private(set) var remainingTime: String = "00:00"
    @Published private(set) var audioPlayer: AVAudioPlayer?
    // TODO: ^ move to view?
    let notificationPublisher = PassthroughSubject<UNMutableNotificationContent, Never>()
    private var transition: Transition?
    private var runningState = RunningState.ready {
        didSet {
            systemImageName = runningState.rawValue
            isStateRunning = runningState == .running
        }
    }
    private let database: Database
    private var timer: Timer?

    init(database: Database) {
        self.database = database
        database.$timeBoxes.map { timeBoxes in
            let from = Calendar.current.startOfDay(for: Date())
            let list = timeBoxes.filter {
                $0.start >= from
            }
            return list.map { timeBox in
                let minutes = Int(timeBox.start.timeIntervalSince(from)) / 60
                return (minutes, timeBox.workMinutes)
            }
        }
        .assign(to: &$spans)
        database.$timeBoxes.map { timeBoxes in
            let map = Dictionary(grouping: timeBoxes) { timeBox in
                Calendar.current.startOfDay(for: timeBox.start)
            }
            let keys = map.keys.sorted(by: >)
            return keys.map { key in
                (Util.date(key), map[key]?.count ?? 00)
            }
        }
        .assign(to: &$counts)
    }

    var isBannerNotification: Bool {
        UserDefaults.standard.bool(forKey: SettingsKeys.TimeBox.isBannerNotification.rawValue)
    }

    var isRemainingTimeViable: Bool {
        switch runningState {
            case .ready:
                false
            case .running:
                true
            case .finished:
                true
        }
    }

    private var breakMinutes: Int {
        UserDefaults.standard.integer(forKey: SettingsKeys.TimeBox.breakMinutes.rawValue)
    }

    private var canPlaySe: Bool {
        UserDefaults.standard.bool(forKey: SettingsKeys.TimeBox.isSoundNotification.rawValue)
    }

    private var durationMinutes: Int {
        UserDefaults.standard.integer(forKey: SettingsKeys.TimeBox.workMinutes.rawValue)
    }

    private var endRestNotification: UNMutableNotificationContent {
        let title = UserDefaults.standard.string(forKey: SettingsKeys.TimeBox.restEndTitle.rawValue)
        ?? SettingsDefaults.TimeBox.restEndTitle
        let body = UserDefaults.standard.string(forKey: SettingsKeys.TimeBox.restEndMessage.rawValue)
        ?? SettingsDefaults.TimeBox.restEndMessage
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = nil
        return content
    }

    private var endWorkNotification: UNMutableNotificationContent {
        let title = UserDefaults.standard.string(forKey: SettingsKeys.TimeBox.workEndTitle.rawValue)
        ?? SettingsDefaults.TimeBox.workEndTitle
        let body = UserDefaults.standard.string(
            forKey: SettingsKeys.TimeBox.workEndMessage.rawValue
        ) ?? SettingsDefaults.TimeBox.workEndMessage
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = nil
        return content
    }

    private var soundVolume: Float {
        if (UserDefaults.standard
            .object(forKey: SettingsKeys.TimeBox.soundVolume.rawValue) != nil) {
            return UserDefaults.standard.float(forKey: SettingsKeys.TimeBox.soundVolume.rawValue)
        } else {
            return SettingsDefaults.TimeBox.soundVolume
        }
    }

    func beginTick() {
        timer?.invalidate()

        let newTimer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tick()
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func makeTransition() {
        transition = .init(
            state: runningState.progressed(),
            queryType: .Button
        )
    }

    func tick() {
        if let transition {
            runningState = transition.state

            switch transition.queryType {
                case .Auto:
                    switch transition.state {
                        case .ready:
                            playSe(
                                fileName: Constants.timeBoxRestEndSound.rawValue,
                                fileType: "mp3"
                            )
                            notificationPublisher.send(endRestNotification)
                        case .running:
                            assert(false, "Should not be running automatically")
                        case .finished:
                            playSe(
                                fileName: Constants.timeBoxEndSound.rawValue,
                                fileType: "mp3"
                            )
                            notificationPublisher.send(endWorkNotification)
                    }
                case .Button:
                    switch transition.state {
                        case .ready:
                            break
                        case .running:
                            playSe(
                                fileName: Constants.timeBoxBeginSound.rawValue,
                                fileType: "mp3"
                            )
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
                        insert(beganAt: beganAt)
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

    private func insert(beganAt: Date) {
        if !isElapsingEnough(beganAt: beganAt) {
            return
        }

        let timeBox = TimeBox(start: beganAt, workMinutes: durationMinutes)

        database.addTimeBox(timeBox)
    }

    private func isElapsingEnough(beganAt: Date) -> Bool {
        let adjustedDuration = TimeInterval(durationMinutes * 60) * 0.9

        return Date().timeIntervalSince(beganAt) >= adjustedDuration
    }

    private func playSe(fileName: String, fileType: String = "wav") {
        if !canPlaySe {
            return
        }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Could not find \(fileName).\(fileType)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = soundVolume
            audioPlayer?.play()
        } catch {
            print("Could not play(\(fileName).\(fileType)): \(error.localizedDescription)")
        }
    }

    private func tickWhileFinished() {
        assert(endAt != nil)

        guard let endAt else {
            return
        }

        let now = Date()
        let elapsedTime = now.timeIntervalSince(endAt)
        let remain = max(breakMinutes * 60 - Int(elapsedTime), 0)
        let minutes = Int(remain) / 60
        let seconds = Int(remain) % 60

        remainingTime = String(format: "%02d:%02d", minutes, seconds)

        if remain == 0 {
            transition = .init(
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
        let remain = max(durationMinutes * 60 - Int(elapsedTime), 0)
        let minutes = Int(remain) / 60
        let seconds = Int(remain) % 60

        remainingTime = String(format: "%02d:%02d", minutes, seconds)

        if remain == 0 {
            transition = .init(
                state: runningState.progressed(),
                queryType: .Auto
            )
        }
    }
}
