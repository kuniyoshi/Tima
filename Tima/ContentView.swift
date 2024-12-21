import SwiftUI

struct ContentView: View {
    @State private var selectedView = 0

    var body: some View {
        VStack {
            Picker("Select", selection: $selectedView) {
                Text("Measurement").tag(0)
                Text("TimeBox").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

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
