import UserNotifications

actor NotificationManager {
    static let shared = NotificationManager()

    private init() {
    }

    @MainActor
    private var showBanner: Bool {
        UserDefaults.standard.bool(forKey: SettingsKeys.Notification.showBanner.rawValue)
    }

    func requestNotificationPermission() async {
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

    @MainActor
    func notify(_ content: UNMutableNotificationContent) {
        if !showBanner {
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
