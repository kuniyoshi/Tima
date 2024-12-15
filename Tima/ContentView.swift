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
    @State private var alertDisplay = AlertDisplay(error: nil)

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
                            let measurement = Measurement(
                                genre: genre,
                                work: work,
                                start: startedAt,
                                end: endedAt
                            )
                            modelContext.insert(measurement)
                            do {
                                try modelContext.save()
                            } catch {
                                print("Failed to save mesurement: \(error)")
                                alertDisplay = alertDisplay
                                    .weakWritten(title: "ERROR", message: "Failed to save measurement: \(error)")
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

            ScrollViewReader { proxy in
                List {
                    ForEach(measurements.reversed()) { measurement in
                        MeasurementView(measurement: measurement)
                            .id(measurement.id)
                    }
                }
                .onChange(of: measurements) {
                    if let lastId = measurements.last?.id {
                        proxy.scrollTo(lastId, anchor: .top)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)

            .alert(isPresented: .constant(alertDisplay.error != nil)) {
                assert(alertDisplay.error != nil)
                return Alert(
                    title: Text(alertDisplay.error?.title ?? "ERROR"),
                    message: Text(alertDisplay.error?.message ?? "Some error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
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
                        print("Could not write JSON data to \(url): \(error)")
                        alertDisplay = alertDisplay
                            .weakWritten(
                                title: "Failed to write JSON data",
                                message: "\(error)"
                            )
                    }
                } else {
                    print("savePanel cancelled")
                }
            }
        } catch {
            print("Failed to encode measurements: \(error)")
            alertDisplay = alertDisplay
                .weakWritten(
                    title: "Failed to encode measurements",
                    message: "\(error)"
                )
        }
    }
}

struct AlertDisplay {
    struct Error {
        var title: String
        var message: String
    }

    var error: Error?

    func cleared() -> AlertDisplay {
        AlertDisplay(error: nil)
    }

    func weakWritten(title: String, message: String) -> AlertDisplay {
        if let error {
            AlertDisplay(error: error)
        } else {
            AlertDisplay(error: Error(title: title, message: message))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Measurement.self, inMemory: true)
}
