import SwiftUI
import SwiftData
import UserNotifications
import AVFoundation
import Combine

// TimeBox main view
struct TimeBoxView: View {
    @StateObject private var model: TimeBoxModel

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

    let subject = PassthroughSubject<Void, Never>()
    let database = Database(
        modelContext: context,
        onRefreshDate: subject.eraseToAnyPublisher(),
        onRefreshAll: subject.eraseToAnyPublisher()
    )
    let model = TimeBoxModel(
        database: database,
        onRefreshDate: subject.eraseToAnyPublisher(),
        onTerminate: subject.eraseToAnyPublisher()
    )

    return TimeBoxView(model: model)
        .modelContainer(container)
}
