import SwiftUI

struct SettingsView: View {
    // TODO: time box と measurement とで構造化して分ける?
    @AppStorage(UserDefaultsKeys.TimeBox.isSoundNotification.rawValue)
    private var notificationWithSound: Bool = true // TODO: user defaults values も必要

    @AppStorage(UserDefaultsKeys.TimeBox.isBannerNotification.rawValue)
    private var notificationFromCenter: Bool = true

    @State private var workMinutes: String = UserDefaults.standard
        .string(forKey: "timeBoxDuration") ?? "25"
    @State private var errorMessageForWorkMinutes: String?
    // TODO: 長い
    @State private var breakMinutes: String = UserDefaults.standard
        .string(forKey: "timeBoxBreakMinutes") ?? "5"
    @State private var errorMessageForBreakMinutes: String?

    var body: some View {
        Form {
            VStack {
                Section(header: Text("Notifications").font(.headline)) {
                    VStack {
                        Toggle("Sound Notification", isOn: $notificationWithSound)
                        Toggle("Center Notification", isOn: $notificationFromCenter)
                    }
                }

                Section(header: Text("TimeBox").font(.headline)) {
                    VStack{
                        VStack {
                            HStack {
                                Text("Work Minutes")
                                TextField("", text: $workMinutes)
                                    .frame(width: 50)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: workMinutes) {
                                        setWorkMinutes(workMinutes)
                                    }

                            }
                            if let errorMessageForWorkMinutes {
                                Text(errorMessageForWorkMinutes)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        VStack {
                            HStack {
                                Text("Break Minutes")
                                TextField("", text: $breakMinutes)
                                    .frame(width: 50)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: breakMinutes) {
                                        setBreakMinutes(breakMinutes)
                                    }
                            }

                            if let errorMessageForBreakMinutes {
                                Text(errorMessageForBreakMinutes)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func setWorkMinutes(_ minutes: String) {
        if let value = Int(minutes) {
            errorMessageForWorkMinutes = nil
            UserDefaults.standard.set(value, forKey: "timeBoxDuration")
        } else {
            errorMessageForWorkMinutes = "Please enter a valid number."
        }
    }

    private func setBreakMinutes(_ minutes: String) {
        if let value = Int(minutes) {
            errorMessageForBreakMinutes = nil
            UserDefaults.standard.set(value, forKey: "timeBoxBreakMinutes")
        } else {
            errorMessageForBreakMinutes = "Please enter a valid number."
        }
    }
}

#Preview {
    SettingsView()
}
