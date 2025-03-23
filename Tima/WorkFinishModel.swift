import UserNotifications

@MainActor
class WorkFinishModel: ObservableObject {
    private let database: Database
    private var lastNotifiedAt: Date?
    private var timer: Timer?

    init(database: Database) {
        self.database = database
    }

    private var dailyWorkMinutes: Int {
        UserDefaults.standard.integer(forKey: SettingsKeys.Measurement.dailyWorkMinutes.rawValue)
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

    private var totalMinutes: Int {
        let calendar = Calendar.current
        let today = Date()

        return database.measurements
            .filter { calendar.isDate($0.start, inSameDayAs: today) }
            .compactMap { measurement in
                Int(measurement.end.timeIntervalSince(measurement.start)) / 60
            }
            .filter { $0 > 0 }
            .reduce(0, +)
    }

    func beginTick() {
        timer?.invalidate()
        timer = nil

        // TODO: make interval longer
        let newTimer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tick()
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func requestNotificationPermission() async {
        await NotificationManager.shared.requestNotificationPermission()
    }

    private func tick() {
        guard totalMinutes >= dailyWorkMinutes else { return }

        if let lastNotifiedAt,
           Calendar.current.isDate(Date(), inSameDayAs: lastNotifiedAt) {
            return
        }

        lastNotifiedAt = Date()
        SoundManager.shared.playSe(fileName: Constants.measurementDailyEndSound.rawValue)
        NotificationManager.shared.notify(notification)
    }
}
