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

    @Environment(\.modelContext) private var modelContext
    @State private var runningState = RunningState.ready
    @State private var beganAt: Date?
    @State private var endAt: Date?
    @State private var remainingTime: String = "00:00"
    @State private var audioPlayer: AVAudioPlayer?

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            HStack {
                Spacer()

                VStack {
                    Button(action: toggleTimeBox) {
                        Image(systemName: runningState.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.green)
                            .padding()
                    }
                    .padding([.top, .leading, .trailing])

                    HStack {
                        if runningState != .ready {
                            Text("Remain")
                            Text(remainingTime).monospacedDigit()
                        }
                    }
                    .onReceive(timer) { _ in
                        onTick()
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            requestNotificationPermission()
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

    private func onTick() {
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
            notify(content: endRestNotification())
            runningState = .ready
            self.endAt = nil
        }
    }

    private func tickWhileRunning() {
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
            notify(content: endWorkNotification())
            runningState = .finished
            endAt = Date()
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

    private func toggleTimeBox() {
        runningState = runningState.progressed()

        switch runningState {
            case .ready:
                playSe(fileName: "rest_end", fileType: "mp3")
                beganAt = nil
            case .running:
                playSe(fileName: "time_box_begin", fileType: "mp3")
                beganAt = Date()
            case .finished:
                pushTimeBoxData(beganAt)
                playSe(fileName: "time_box_end", fileType: "mp3")
                beganAt = nil
                endAt = Date()
        }
    }

    func pushTimeBoxData(_ beganAt: Date?) {
        assert(beganAt != nil)

        guard let beganAt else {
            return
        }

        let duration = UserDefaults.standard.integer(forKey: SettingsKeys.TimeBox.workMinutes.rawValue)
        let adjustedDuration = TimeInterval(duration) * 0.9

        if (Date().timeIntervalSince(beganAt) < adjustedDuration) {
            return
        }

        let timeBoxData = TimeBox(start: beganAt, workMinutes: duration)

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
    TimeBoxView()
}
