import SwiftUI

struct ContentView: View {
    @State private var selectedView = 0

    var body: some View {
        VStack {
            Picker(selection: $selectedView, label: EmptyView()) {
                Text("Measurement").tag(0)
                Text("TimeBox").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            Button(action: {
                selectedView = 0
            }) {
                Text("Select measurement")
            }
            .keyboardShortcut("1", modifiers: .command)
            .frame(width: 0, height: 0)
            .opacity(0)

            Button(action: {
                selectedView = 1
            }) {
                Text("Select timeBox")
            }
            .keyboardShortcut("2", modifiers: .command)
            .frame(width: 0, height: 0)
            .opacity(0)

            Spacer()

            if selectedView == 0 {
                MeasurementView()
            } else {
                TimeBoxView()
            }

            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
