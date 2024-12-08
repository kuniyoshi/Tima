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

//                        if isRunning,
//                           let startedAt,
//                           let endedAt{
//                            let mesurement = Measurement(
//                                genre: genre,
//                                work: work,
//                                start: startedAt,
//                                end: endedAt
//                            )
//                            modelContext.insert(mesurement)
//                            do {
//                                try modelContext.save()
//                            } catch {
//                                print("Failed to save mesurement: \(error)")
//                            }
//                        }

                        isRunning.toggle()
                    }) {
                        Image(systemName: isRunning ? "pause.circle" : "play.circle")
                            .font(.title)
                    }
                    .padding()
            }
            List {
                ForEach(measurements) { measurement in
                    MeasurementView(measurement: measurement)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
