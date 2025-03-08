import UserNotifications
import SwiftUI

@MainActor
class MeasurementTotalTimeModel: ObservableObject {
    @Published private(set) var totalMinutes: Int
    private var lastPublishedAt: Date?

    init(totalMinutes: Int = 0) {
        self.totalMinutes = totalMinutes
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

        if totalMinutes < dailyWorkMinutes {
            return
        }

        let calendar = Calendar.current

        if let lastPublishedAt,
           calendar.isDate(lastPublishedAt, inSameDayAs: Date()) {
            return
        }

        SoundManager.shared.playSe(fileName: Constants.measurementDailyEndSound.rawValue)
        NotificationManager.shared.notify(notification)
        lastPublishedAt = Date()
    }
}
