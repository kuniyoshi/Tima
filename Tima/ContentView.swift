import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var measurements: [Measurement]
    @State private var genre: String = ""
    @State private var work: String = ""
    @State private var isRunning: Bool = false
    @State private var startedAt: Date?
    @State private var endedAt: Date?


    var body: some View {
        VStack {
            HStack {
                TextField("Input genre...", text: $genre)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Input work...", text: $work)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(
                    action: {
                        if isRunning {
                            startedAt = Date()
                        } else {
                            endedAt = Date()
                        }

                        assert(!isRunning || (isRunning && startedAt != nil && endedAt != nil))

                        if isRunning,
                           let startedAt,
                           let endedAt{
                            let mesurement = Measurement(
                                genre: genre,
                                work: work,
                                start: startedAt,
                                end: endedAt
                            )
                            modelContext.insert(mesurement)
                            do {
                                try modelContext.save()
                            } catch {
                                print("Failed to save mesurement: \(error)")
                            }
                        }

                        isRunning.toggle()
                    }) {
                        Image(systemName: isRunning ? "pause.circle" : "play.circle")
                            .font(.title)
                    }
                    .padding()
            }
            HStack {
                Spacer()
                Button(action: exportMeasurements) {
                    Text("Export Data")
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding()

            List {
                ForEach(measurements) { measurement in
                    MeasurementView(measurement: measurement)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        }
    }

    private func exportMeasurements() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(measurements)
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.json]
            savePanel.nameFieldStringValue = "measurements.json"
            savePanel.canCreateDirectories = true
            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    do {
                        try jsonData.write(to: url)
                    } catch {
                        //
                    }
                } else {
                    //
                }
            }
        } catch {
            print("Failed to encode measurements: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Measurement.self, inMemory: true)
}
