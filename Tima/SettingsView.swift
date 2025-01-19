import SwiftUI
import AVFoundation

// Represents App's settings
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

    @State private var soundVolume: Float = {
        if UserDefaults.standard
            .object(forKey: SettingsKeys.TimeBox.soundVolume.rawValue) != nil {
            return UserDefaults.standard.float(forKey: SettingsKeys.TimeBox.soundVolume.rawValue)
        } else {
            return 0.5
        }
    }()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlayButtonAnimating: Bool = false

    var body: some View {
        Form {
            VStack {
                Section(header: Text("Notifications").font(.headline)) {
                    VStack {
                        Toggle("Sound Notification", isOn: $notificationWithSound)
                        Toggle("Center Notification", isOn: $notificationFromCenter)
                    }
                }

                // TODO: disable while no sound notification
                Section(header: Text("Sound Volume").font(.headline)) {
                    HStack {
                        Slider(value: $soundVolume)
                            .frame(width: 240)
                            .onChange(of: soundVolume) {
 _,
 newValue in
                                audioPlayer?.volume = newValue
                                UserDefaults.standard
                                    .set(
                                        newValue,
                                        forKey: SettingsKeys.TimeBox.soundVolume.rawValue
                                    )
                            }

                        Button(action: {
                            do {
                                // TODO: dont fix se, rotate
                                // TODO: avoid literal
                                guard let url = Bundle.main.url(forResource: "time_box_begin", withExtension: "mp3") else {
                                    print("Could not find sample sound file")
                                    return
                                }

                                let newAudioPlayer = try AVAudioPlayer(contentsOf: url)
                                newAudioPlayer.volume = soundVolume
                                newAudioPlayer.play()
                                audioPlayer = newAudioPlayer
                            } catch {
                                print("Could not play sound: \(error)")
                            }
                        }) {
                            Image(systemName: "play")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .scaleEffect(isPlayButtonAnimating ? 1.2 : 1.0) // TODO: it is not working
                        }
                    }
                }

                // TODO: time box is too general
                Section(header: Text("TimeBox").font(.headline)) {
                    VStack {
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
