import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKeys.TimeBox.isSoundNotification.rawValue)
    private var notificationWithSound: Bool = SettingsDefaults.TimeBox.isSoundNotification

    @AppStorage(SettingsKeys.TimeBox.isBannerNotification.rawValue)
    private var notificationFromCenter: Bool = SettingsDefaults.TimeBox.isBannerNotification

    @State private var workMinutes: String = UserDefaults.standard
        .string(forKey: SettingsKeys.TimeBox.workMinutes.rawValue) ?? String(SettingsDefaults.TimeBox.workMinutes)
    @State private var errorMessageForWorkMinutes: String?
    // TODO: 長い
    @State private var breakMinutes: String = UserDefaults.standard
        .string(forKey: SettingsKeys.TimeBox.breakMinutes.rawValue) ?? String(SettingsDefaults.TimeBox.breakMinutes)
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
            UserDefaults.standard.set(value, forKey: SettingsKeys.TimeBox.workMinutes.rawValue)
        } else {
            errorMessageForWorkMinutes = "Please enter a valid number."
        }
    }

    private func setBreakMinutes(_ minutes: String) {
        if let value = Int(minutes) {
            errorMessageForBreakMinutes = nil
            UserDefaults.standard.set(value, forKey: SettingsKeys.TimeBox.breakMinutes.rawValue)
        } else {
            errorMessageForBreakMinutes = "Please enter a valid number."
        }
    }
}

#Preview {
    SettingsView()
}
