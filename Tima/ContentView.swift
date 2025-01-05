import SwiftUI

struct ContentView: View {
    @State private var selectedView = 0

    var body: some View {
        NavigationStack {
            VStack {
                if selectedView == 0 {
                    MeasurementView()
                } else {
                    TimeBoxView()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button("Measurement") {
                        selectedView = 0
                    }
                    .keyboardShortcut("1", modifiers: .command)

                    Button("TimeBox") {
                        selectedView = 1
                    }
                    .keyboardShortcut("2", modifiers: .command)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
