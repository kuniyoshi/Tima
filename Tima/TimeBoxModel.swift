import SwiftUI
import AVFoundation

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
    @Published var transition: Transition?
    private let database: Database

    init(database: Database) {
        self.database = database
    }

    @MainActor
    func insert(beganAt: Date) {
        let durationMinutes = UserDefaults.standard.integer(forKey: SettingsKeys.TimeBox.workMinutes.rawValue)
        let adjustedDuration = TimeInterval(durationMinutes * 60) * 0.9

        if (Date().timeIntervalSince(beganAt) < adjustedDuration) {
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
}
