import SwiftUI
import SwiftData
import UserNotifications
import AVFoundation

struct TimeBoxView: View {
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

    @State private var runningState = RunningState.ready
    @State private var beganAt: Date?
    @State private var endAt: Date?
    @State private var remainingTime: String = "00::00"

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
                        if beganAt != nil {
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
        if let beganAt {
            let now = Date()
            let elapsedTime = now.timeIntervalSince(beganAt)
            let remain = max(25 * 60 - elapsedTime, 0)
            let minutes = Int(remain) / 60
            let seconds = Int(remain) % 60

            remainingTime = String(format: "%02d:%02d", minutes, seconds)

            if remain == 0 {
                notify()
                runningState = .finished
                self.beganAt = nil
            }
        }
    }

    private func notify() {
        let content = UNMutableNotificationContent()
        content.title = "Time's up!"
        content.body = "TimeBox finished!  Good work!"
        content.sound = .default

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
                beganAt = nil
            case .running:
                beganAt = Date()
            case .finished:
                beganAt = nil
        }
    }
}

#Preview {
    TimeBoxView()
}
