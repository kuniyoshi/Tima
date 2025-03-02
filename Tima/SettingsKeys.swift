// Application settings keys
enum SettingsKeys {
    enum Measurement: String {
        case dailyWorkMinutes = "measurement.dailyWorkMinutes"
        case dailyEndTitle = "measurement.dailyEndTitle"
        case dailyEndMessage = "measurement.dailyEndMessage"
    }

    enum TimeBox: String {
        case isSoundNotification = "timeBox.isSoundNotification" // TODO: commonize
        case isBannerNotification = "timeBox.isBannerNotification"
        case workMinutes = "timeBox.workMinutes"
        case breakMinutes = "timeBox.breakMinutes"
        case soundVolume = "timeBox.soundVolume"
        case workEndTitle = "timeBox.workEndTitle"
        case workEndMessage = "timeBox.workEndMessage"
        case restEndTitle = "timeBox.restEndTitle"
        case restEndMessage = "timeBox.restEndMessage"
    }
}
