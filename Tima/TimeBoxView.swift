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
            Button(action: model.makeTransition) {
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
            await requestNotificationPermission()
        }
        .onAppear {
            model.notificationPublisher.sink { content in
                notify(content: content)
            }
            .store(in: &cancellable)
            model.makeTransition()
            model.beginTick()
        }
    }

    init(model: TimeBoxModel) {
        _model = .init(wrappedValue: model)
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
