import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaultsKeys.notificationWithSound.rawValue) var notificationWithSound: Bool = true
    @AppStorage(UserDefaultsKeys.notificationFromCenter.rawValue) var notificationFromCenter: Bool = true

    var body: some View {
        Form {
            HStack {
                Text("Notification")
                Spacer()
                VStack {
                    Toggle("Sound Notification", isOn: $notificationWithSound)
                    Toggle("Center Notification", isOn: $notificationFromCenter)
                }
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
