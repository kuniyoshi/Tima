import Combine
import UserNotifications
import SwiftUI

@MainActor
class MeasurementTotalTimeModel: ObservableObject {
    @Published private(set) var totalMinutes: Int
    let notificationPublisher = PassthroughSubject<UNMutableNotificationContent, Never>()
    private var lastPublishedAt: Date?
    private var cancellables: Set<AnyCancellable> = []

    init(totalMinutes: Int = 0) {
        self.totalMinutes = totalMinutes

        $totalMinutes
            .sink { [unowned self] newValue in
                if newValue < dailyWorkMinutes {
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

    private var notification: UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = UserDefaults.standard.string(forKey: SettingsKeys.Measurement.dailyEndTitle.rawValue)
        ?? SettingsDefaults.Measurement.dailyEndTitle
        content.body = UserDefaults.standard.string(forKey: SettingsKeys.Measurement.dailyEndMessage.rawValue)
        ?? SettingsDefaults.Measurement.dailyEndMessage
        content.sound = nil
        return content
    }

    private var dailyWorkMinutes: Int {
        UserDefaults.standard.integer(forKey: SettingsKeys.Measurement.dailyWorkMinutes.rawValue)
    }

    func setValue(_ value: Int) {
        totalMinutes = value
    }
}
