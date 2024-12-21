import SwiftUI

struct PreferencesView: View {
    @AppStorage("notificationWithSound") var notificationWithSound: Bool = true
    @AppStorage("notificationFromCenter") var notificationFromCenter: Bool = true

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
    PreferencesView()
}
