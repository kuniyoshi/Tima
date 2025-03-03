import SwiftUI
import SwiftData
import UserNotifications
import AVFoundation
import Combine

// TimeBox main view
struct TimeBoxView: View {
    @StateObject private var model: TimeBoxModel
    @State private var cancellable: Set<AnyCancellable> = []

    var body: some View {
        VStack {
            Button(action: onButton) {
                Image(systemName: model.systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                    .padding()
            }
            .padding([.top, .leading, .trailing])
            .keyboardShortcut(" ", modifiers: [])

            HStack {
                if model.isRemainingTimeViable {
                    Text("Remain")
                    Text(model.remainingTime).monospacedDigit()
                }
            }

            HStack {
                Spacer()

                TimeBoxCountView(spans: model.spans)
                    .padding()

                Spacer()
            }

            TimeBoxListView(model.counts)
        }
        .task {
            await NotificationManager.shared.requestNotificationPermission()
        }
        .onAppear {
            model.notificationPublisher.sink { content in
                notify(content: content)
            }
            .store(in: &cancellable)
            model.beginTick()
        }
    }

    init(model: TimeBoxModel) {
        _model = .init(wrappedValue: model)
    }

    private func onButton() {
        model.makeTransition()
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [Constants.notificationID.rawValue])
    }

    private func notify(content: UNMutableNotificationContent) {
        if !model.isBannerNotification {
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: Constants.notificationID.rawValue,
            content: content,
            trigger: trigger
        )

        Task {
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
