import Combine
import SwiftUI
import UserNotifications

struct MeasurementTotalTimeView: View {
    @StateObject private var model: MeasurementTotalTimeModel

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
        .task {
            await NotificationManager.shared.requestNotificationPermission()
        }
    }

    init(model: MeasurementTotalTimeModel) {
        _model = .init(wrappedValue: model)
    }
}

#Preview {
    MeasurementTotalTimeView(model: MeasurementTotalTimeModel())
}
