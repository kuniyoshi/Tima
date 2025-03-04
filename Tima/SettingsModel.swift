import SwiftUI

class SettingsModel: ObservableObject {
    class SettingsNumberItem: ObservableObject {
        @Published var value: String {
            didSet {
                error = nil
                if let newValue = Int(value) {
                    UserDefaults.standard.set(newValue, forKey: key)
                } else {
                    error = "Please enter a valid number."
                }
            }
        }
        @Published var error: String?
        private let key: String

        init(_ value: String, forKey: String) {
            self.value = value
            self.key = forKey
        }
    }

    var workMinutes: SettingsNumberItem
    var breakMinutes: SettingsNumberItem
    var dailyWorkMinutes: SettingsNumberItem

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
    @Published var onDailyEndTitle: String {
        didSet {
            UserDefaults.standard
                .set(onDailyEndTitle, forKey: SettingsKeys.Measurement.dailyEndTitle.rawValue)
        }
    }
    @Published var onDailyEndMessage: String {
        didSet {
            UserDefaults.standard
                .set(onDailyEndMessage, forKey: SettingsKeys.Measurement.dailyEndMessage.rawValue)
        }
    }

    init() {
        workMinutes = SettingsNumberItem(
            UserDefaults.standard.string(forKey: SettingsKeys.TimeBox.workMinutes.rawValue)
            ?? String(SettingsDefaults.TimeBox.workMinutes),
            forKey: SettingsKeys.TimeBox.workMinutes.rawValue
        )

        breakMinutes = SettingsNumberItem(
            UserDefaults.standard.string(forKey: SettingsKeys.TimeBox.breakMinutes.rawValue)
            ?? String(SettingsDefaults.TimeBox.breakMinutes),
            forKey: SettingsKeys.TimeBox.breakMinutes.rawValue
        )
        dailyWorkMinutes = SettingsNumberItem(
            UserDefaults.standard.string(forKey: SettingsKeys.Measurement.dailyWorkMinutes.rawValue)
            ?? String(SettingsDefaults.Measurement.dailyWorkMinutes),
            forKey: SettingsKeys.Measurement.dailyWorkMinutes.rawValue
        )

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
        _onDailyEndTitle = .init(
            initialValue: UserDefaults.standard.string(forKey: SettingsKeys.Measurement.dailyEndTitle.rawValue)
            ?? SettingsDefaults.Measurement.dailyEndTitle
        )
        _onDailyEndMessage = .init(
            initialValue: UserDefaults.standard
                .string(forKey: SettingsKeys.Measurement.dailyEndMessage.rawValue)
            ?? SettingsDefaults.Measurement.dailyEndMessage
        )
    }
}
