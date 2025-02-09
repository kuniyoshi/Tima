import SwiftUI
import SwiftData
import UserNotifications
import AVFoundation

// TimeBox main view
struct TimeBoxView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timeBoxes: [TimeBox]
    @StateObject private var model: TimeBoxModel
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Button(action: onButton) {
                Image(systemName: model.runningState.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                    .padding()
            }
            .padding([.top, .leading, .trailing])
            .keyboardShortcut(" ", modifiers: [])

            HStack {
                if model.runningState != .ready {
                    Text("Remain")
                    Text(model.remainingTime).monospacedDigit()
                }
            }

            HStack {
                Spacer()

                TimeBoxCountView(spans: makeSpans(timeBoxes))
                    .padding()

                Spacer()
            }

            TimeBoxListView(makeCounts(timeBoxes))
        }
        .task {
            await TickManager.shared.setTimer(interval: 0.01) {
                SwiftUI.Task {
                    await MainActor.run {
                        onTick()
                    }
                }
            }
            await requestNotificationPermission()
        }
    }

    init(model: TimeBoxModel) {
        _model = .init(wrappedValue: model)
    }

    private func makeCounts(_ timeBoxes: [TimeBox]) -> [(String, Int)] {
        let map = Dictionary(grouping: timeBoxes) { timeBox in
            Calendar.current.startOfDay(for: timeBox.start)
        }
        let keys = map.keys.sorted(by: >)
        return keys.map { key in
            (Util.date(key), map[key]?.count ?? 00)
        }
    }

    private func makeSpans(_ timeBoxes: [TimeBox]) -> [(Int, Int)] {
        let from = Calendar.current.startOfDay(for: Date())
        let list = timeBoxes.filter {
            $0.start >= from
        }
        return list.map { timeBox in
            let minutes = Int(timeBox.start.timeIntervalSince(from)) / 60
            return (minutes, timeBox.workMinutes)
        }
    }

    private func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            if try await center.requestAuthorization(options: [.alert, .sound]) {
                print("Notification granted")
            } else {
                print("Notification denied")
            }
        } catch {
            print("Could not request notification permission: \(error.localizedDescription)")
        }
    }

    private func onButton() {
        model.transition = .init(
            state: model.runningState.progressed(),
            queryType: .Button
        )
    }

    private func onTick() {
        if let transition = model.transition {
            model.runningState = transition.state

            switch transition.queryType {
            case .Auto:
                switch transition.state {
                case .ready:
                        model.playSe(
                            fileName: Constants.timeBoxRestEndSound.rawValue,
                            fileType: "mp3"
                        )
                        notify(content: model.endRestNotification())
                case .running:
                    assert(false, "Should not be running automatically")
                case .finished:
                        model.playSe(
                            fileName: Constants.timeBoxEndSound.rawValue,
                            fileType: "mp3"
                        )
                        notify(content: model.endWorkNotification())
                }
            case .Button:
                switch transition.state {
                case .ready:
                    break
                case .running:
                        model.playSe(
                            fileName: Constants.timeBoxBeginSound.rawValue,
                            fileType: "mp3"
                        )
                case .finished:
                    break
                }
            }

            switch transition.state {
            case .ready:
                model.beganAt = nil
                model.endAt = nil
                timer = nil
            case .running:
                model.beganAt = Date()
            case .finished:
                model.endAt = Date()
                if let beganAt = model.beganAt {
                    model.insert(beganAt: beganAt)
                } else {
                    print("No beganAt found")
                }
            }

            self.model.transition = nil
        }

        switch model.runningState {
        case .ready:
            break
        case .running:
                model.tickWhileRunning()
        case .finished:
                model.tickWhileFinished()
        }
    }

    private func notify(content: UNMutableNotificationContent) {
        if !model.isBannerNotification {
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        SwiftUI.Task {
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Could not add notification: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: TimeBox.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    context.insert(TimeBox(start: Date(), workMinutes: 25))
    context.insert(TimeBox(start: Date(), workMinutes: 25))
    context.insert(TimeBox(start: Date(), workMinutes: 25))
    context.insert(TimeBox(start: Date(), workMinutes: 25))

    context.insert(TimeBox(start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, workMinutes: 25))
    context.insert(TimeBox(start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, workMinutes: 25))

    context.insert(TimeBox(start: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, workMinutes: 25))
    context.insert(TimeBox(start: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, workMinutes: 25))

    let database = Database(modelContext: context)

    return TimeBoxView(model: TimeBoxModel(database: database))
        .modelContainer(container)
}
