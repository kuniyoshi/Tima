import Combine
import SwiftUI
import UserNotifications

struct MeasurementTotalTimeView: View {
    @StateObject private var model: MeasurementTotalTimeModel
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        HStack {
            Text("total")
                .padding(.horizontal)
                .font(.caption)
            Text("\(model.totalMinutes)")
                .foregroundColor(.accentColor)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
            Text("min")
                .font(.caption)
        }
        .padding(.horizontal)
        .onAppear {
            model.notificationPublisher.sink { notification in
                notify(content: notification)
            }
            .store(in: &cancellables)
        }
    }

    init(model: MeasurementTotalTimeModel) {
        _model = .init(wrappedValue: model)
    }

    private func notify(content: UNMutableNotificationContent) {
        // TODO: settings where notify or not

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "notification", // TODO: commonize
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
    MeasurementTotalTimeView(model: MeasurementTotalTimeModel())
}
