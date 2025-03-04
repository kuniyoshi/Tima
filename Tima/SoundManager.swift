import AVFoundation

@MainActor
class SoundManager {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {
    }

    private var canPlaySe: Bool {
        UserDefaults.standard.bool(forKey: SettingsKeys.Notification.playSound.rawValue)
    }

    private var soundVolume: Float {
        if (UserDefaults.standard
            .object(forKey: SettingsKeys.TimeBox.soundVolume.rawValue) != nil) {
            return UserDefaults.standard.float(forKey: SettingsKeys.TimeBox.soundVolume.rawValue)
        } else {
            return SettingsDefaults.TimeBox.soundVolume
        }
    }

    func playSe(fileName: String) {
        if !canPlaySe {
            return
        }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Could not find \(fileName).mp3")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = soundVolume
            audioPlayer?.play()
        } catch {
            print("Could not play(\(fileName).mp3): \(error.localizedDescription)")
        }
    }
}
