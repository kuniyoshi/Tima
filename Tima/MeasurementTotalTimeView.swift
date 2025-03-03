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
                notify(notification)
            }
            .store(in: &cancellables)
        }
        .task {
            await NotificationManager.shared.requestNotificationPermission()
        }
    }

    init(model: MeasurementTotalTimeModel) {
        _model = .init(wrappedValue: model)
    }

    func notify(_ content: UNMutableNotificationContent) {
        if model.canNotify {
            NotificationManager.shared.notify(content)
        }
    }
}

#Preview {
    MeasurementTotalTimeView(model: MeasurementTotalTimeModel())
}
