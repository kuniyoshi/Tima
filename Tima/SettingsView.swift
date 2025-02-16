import SwiftUI
import AVFoundation

// Represents App's settings
struct SettingsView: View {
    private enum SampleSe {
        case begin
        case end
        case next

        func progressed() -> Self {
            switch self {
                case .begin: return .end
                case .end: return .next
                case .next: return .begin
            }
        }

        var url: URL? {
            switch self {
                case .begin:
                    return Bundle.main.url(forResource: Constants.timeBoxBeginSound.rawValue, withExtension: "mp3")
                case .end:
                    return Bundle.main.url(forResource: Constants.timeBoxEndSound.rawValue, withExtension: "mp3")
                case .next:
                    return Bundle.main.url(forResource: Constants.timeBoxRestEndSound.rawValue, withExtension: "mp3")
            }
        }
    }

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
            return SettingsDefaults.TimeBox.soundVolume
        }
    }()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var nextSound: SampleSe = .begin
    @State private var model: SettingsModel

    var body: some View {
        Form {
            VStack {
                Section(header: Text("Notifications").font(.headline)) {
                    VStack {
                        Toggle("Sound Notification", isOn: $notificationWithSound)
                        Toggle("Center Notification", isOn: $notificationFromCenter)
                    }
                }

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
                            .disabled(!notificationWithSound)

                        Button(action: {
                            do {
                                let sound = nextSound
                                nextSound = sound.progressed()

                                guard let url = sound.url else {
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
                        }
                        .disabled(!notificationWithSound)
                    }
                }

                Section(header: Text("Spans").font(.headline)) {
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

                Section(header: Text("Message").font(.headline)) {
                    Section(header: Text("On worked").font(.subheadline)) {
                        VStack {
                            TextField("Title", text: $model.onWorkedTitle)
                            TextField("Message", text: $model.onWorkedMessage)
                        }
                    }
                    Section(header: Text("On rested").font(.subheadline)) {
                        VStack {
                            TextField("Title", text: $model.onRestedTitle)
                            TextField("Message", text: $model.onRestedMessage)
                        }
                    }
                }
            }
        }
        .padding()
    }

    init(model: SettingsModel) {
        _model = .init(wrappedValue: model)
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
    SettingsView(model: .init())
}
