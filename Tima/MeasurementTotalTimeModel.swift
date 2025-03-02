import Combine
import UserNotifications
import SwiftUI

@MainActor
class MeasurementTotalTimeModel: ObservableObject {
    @Published private(set) var totalMinutes: Int
    let notificationPublisher = PassthroughSubject<UNMutableNotificationContent, Never>()
    private var lastPublishedAt: Date?
    private var cancellables: Set<AnyCancellable> = []

    private var notification: UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Yeah!" // TODO: settings
        content.body = "Today's work is over!"
        content.sound = nil
        return content
    }

    init(totalMinutes: Int = 0) {
        self.totalMinutes = totalMinutes

        $totalMinutes
            .sink { [unowned self] newValue in
                if newValue < 4 { // TODO: settings
                    return
                }

                let calendar = Calendar.current
                if let lastPublishedAt = self.lastPublishedAt,
                   calendar.isDate(lastPublishedAt, inSameDayAs: Date()) {
                    return
                }
                SoundManager.shared.playSe(fileName: Constants.measurementDailyEndSound.rawValue)
                notificationPublisher.send(notification)
                lastPublishedAt = Date()
            }
            .store(in: &cancellables)
    }

    func setValue(_ value: Int) {
        totalMinutes = value
    }
}
