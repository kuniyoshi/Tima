import SwiftUI

class SettingsModel: ObservableObject {
    @Published var onWorkedTitle: String {
        didSet {
            UserDefaults.standard.set(onWorkedTitle, forKey: SettingsKeys.TimeBox.workEndTitle.rawValue)
        }
    }
    @Published var onWorkedMessage: String {
        didSet {
            UserDefaults.standard.set(onWorkedMessage, forKey: SettingsKeys.TimeBox.workEndMessage.rawValue)
        }
    }
    @Published var onRestedTitle: String {
        didSet {
            UserDefaults.standard
                .set(onRestedTitle, forKey: SettingsKeys.TimeBox.restEndTitle.rawValue)
        }
    }
    @Published var onRestedMessage: String {
        didSet {
            UserDefaults.standard
                .set(onRestedMessage, forKey: SettingsKeys.TimeBox.restEndMessage.rawValue)
        }
    }

    init() {
        _onWorkedTitle = .init(
            initialValue: UserDefaults.standard.string(forKey: SettingsKeys.TimeBox.workEndTitle.rawValue)
            ?? SettingsDefaults.TimeBox.workEndTitle
        )
        _onWorkedMessage = .init(
            initialValue: UserDefaults.standard
                .string(forKey: SettingsKeys.TimeBox.workEndMessage.rawValue)
            ?? SettingsDefaults.TimeBox.workEndMessage
        )
        _onRestedTitle = .init(
            initialValue: UserDefaults.standard
                .string(forKey: SettingsKeys.TimeBox.restEndTitle.rawValue)
            ?? SettingsDefaults.TimeBox.restEndTitle
        )
        _onRestedMessage = .init(
            initialValue: UserDefaults.standard.string(forKey: SettingsKeys.TimeBox.restEndMessage.rawValue)
            ?? SettingsDefaults.TimeBox.restEndMessage
        )
    }
}
