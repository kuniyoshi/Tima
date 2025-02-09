import SwiftUI
import AVFoundation
import UserNotifications
import Combine

// TimeBox model
class TimeBoxModel: ObservableObject {
    enum RunningState: String {
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

    enum QueryType {
        case Auto
        case Button
    }

    struct Transition {
        var state: RunningState
        var queryType: QueryType
    }

    @Published var runningState = RunningState.ready
    @Published var beganAt: Date?
    @Published var endAt: Date?
    @Published var remainingTime: String = "00:00"
    @Published var audioPlayer: AVAudioPlayer? // TODO: 通知のオプションでならせないのかどうか
    // TODO: ^ move to view?
    @Published var transition: Transition?
    let notificationPublisher = PassthroughSubject<UNMutableNotificationContent, Never>()
    private let database: Database

    init(database: Database) {
        self.database = database
    }

    var isBannerNotification: Bool {
        UserDefaults.standard.bool(forKey: SettingsKeys.TimeBox.isBannerNotification.rawValue)
    }

    private var breakMinutes: Int {
        UserDefaults.standard.integer(forKey: SettingsKeys.TimeBox.breakMinutes.rawValue)
    }

    private var durationMinutes: Int {
        UserDefaults.standard.integer(forKey: SettingsKeys.TimeBox.workMinutes.rawValue)
    }

    func endRestNotification() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time to Focus"
        content.body = "Break is over.  It's time to focus and get back to work!"
        content.sound = nil
        return content
    }

    func endWorkNotification() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time's up!"
        content.body = "TimeBox finished!  Good work!"
        content.sound = nil
        return content
    }

    @MainActor
    func insert(beganAt: Date) {
        if isElapsingEnough(beganAt: beganAt) {
            return
        }

        let timeBox = TimeBox(start: beganAt, workMinutes: durationMinutes)

        database.addTimeBox(timeBox)
    }

    func playSe(fileName: String, fileType: String = "wav") {
        if !canPlaySe() {
            return
        }

        // TODO: 通知のサウンドをカスタムする?

        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Could not find \(fileName).\(fileType)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = getSoundVolume()
            audioPlayer?.play()
        } catch {
            print("Could not play(\(fileName).\(fileType)): \(error.localizedDescription)")
        }
    }

    @MainActor
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
                            notificationPublisher.send(endRestNotification())
                        case .running:
                            assert(false, "Should not be running automatically")
                        case .finished:
                            playSe(
                                fileName: Constants.timeBoxEndSound.rawValue,
                                fileType: "mp3"
                            )
                            notificationPublisher.send(endWorkNotification())
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

    func tickWhileFinished() {
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

    func tickWhileRunning() {
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

    private func canPlaySe() -> Bool {
        UserDefaults.standard.bool(forKey: SettingsKeys.TimeBox.isSoundNotification.rawValue)
    }

    private func getSoundVolume() -> Float {
        if (UserDefaults.standard
            .object(forKey: SettingsKeys.TimeBox.soundVolume.rawValue) != nil) {
            return UserDefaults.standard.float(forKey: SettingsKeys.TimeBox.soundVolume.rawValue)
        } else {
            return SettingsDefaults.TimeBox.soundVolume
        }
    }

    private func isElapsingEnough(beganAt: Date) -> Bool {
        let adjustedDuration = TimeInterval(durationMinutes * 60) * 0.9

        return Date().timeIntervalSince(beganAt) >= adjustedDuration
    }
}
