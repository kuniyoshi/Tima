// Application settings
struct SettingsDefaults {
    struct TimeBox {
        static let isSoundNotification: Bool = true
        static let isBannerNotification: Bool = true
        static let workMinutes: Int = 25
        static let breakMinutes: Int = 5
        static let soundVolume: Float = 0.5
        static let workEndTitle = "Time's up!"
        static let workEndMessage = "TimeBox finished!  Good work!"
        static let restEndTitle = "Time to Focus"
        static let restEndMessage = "Break is over.  It's time to focus and get back to work!"
    }
}
