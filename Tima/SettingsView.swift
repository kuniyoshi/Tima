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

    @AppStorage(SettingsKeys.Notification.playSound.rawValue)
    private var notificationWithSound: Bool = SettingsDefaults.TimeBox.isSoundNotification

    @AppStorage(SettingsKeys.Notification.showBanner.rawValue)
    private var notificationFromCenter: Bool = SettingsDefaults.TimeBox.isBannerNotification

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
                            .onChange(of: soundVolume) { _, newValue in
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
                                TextField("", text: $model.workMinutes.value)
                                    .frame(width: 60)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .multilineTextAlignment(.trailing)
                            }

                            if let error = model.workMinutes.error {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        VStack {
                            HStack {
                                Text("Break Minutes")
                                TextField("", text: $model.breakMinutes.value)
                                    .frame(width: 60)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .multilineTextAlignment(.trailing)
                            }

                            if let error = model.breakMinutes.error {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        VStack {
                            HStack {
                                Text("Daily work minutes")
                                TextField("", text: $model.dailyWorkMinutes.value)
                                    .frame(width: 60)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .multilineTextAlignment(.trailing)
                            }

                            if let error = model.dailyWorkMinutes.error {
                                Text(error)
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

                    Section(header: Text("On day end").font(.subheadline)) {
                        VStack {
                            TextField("Title", text: $model.onDailyEndTitle)
                            TextField("Message", text: $model.onDailyEndMessage)
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
}

#Preview {
    SettingsView(model: .init())
}
