import SwiftUI

struct MeasurementItem: View {
    @Environment(\.modelContext) private var context
    @State private var measurement: Measurement

    @State private var genre: String
    @State private var work: String
    @State private var startDate: Date
    @State private var endDate: Date

    @State private var isGenreEditing = false
    @State private var isWorkEditing = false
    @State private var isStartDateEditing = false
    @State private var isEndDateEditing = false

    @FocusState private var isGenreFocused: Bool
    @FocusState private var isWorkFocused: Bool
    @FocusState private var isStartDateFocused: Bool
    @FocusState private var isEndDateFocused: Bool

    init(measurement: Measurement) {
        self.measurement = measurement
        self._genre = State(initialValue: measurement.genre)
        self._work = State(initialValue: measurement.work)
        self._startDate = State(initialValue: measurement.start)
        self._endDate = State(initialValue: measurement.end)
    }

    var body: some View {
        HStack {
            if isGenreEditing {
                TextField(genre, text: $genre)
                    .focused($isGenreFocused)
                    .onAppear {
                        isGenreFocused = true
                    }
                    .onSubmit {
                        isGenreEditing = false
                        updateMeasurement {
                            measurement.genre = genre
                        }
                    }
            } else {
                Text(measurement.genre)
                    .onTapGesture {
                        isGenreEditing = true
                    }
                    .foregroundColor(.primary)
            }

            if isWorkEditing {
                TextField(work, text: $work)
                    .focused($isWorkFocused)
                    .onAppear {
                        isWorkFocused = true
                    }
                    .onSubmit {
                        isWorkEditing = false
                        updateMeasurement{
                            measurement.work = work
                        }
                    }
            } else {
                Text(measurement.work)
                    .onTapGesture {
                        isWorkEditing = true
                    }
                    .foregroundColor(.primary)
            }

            Spacer()

            HStack {
                if isStartDateEditing {
                    DatePicker("", selection: $startDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .focused($isStartDateFocused)
                        .onChange(of: isStartDateFocused) { _, newValue in
                            if !newValue {
                                isStartDateEditing = false
                                updateMeasurement {
                                    measurement.start = startDate
                                }
                            }
                        }
                        .onAppear {
                            isStartDateFocused = true
                        }
                        .onSubmit {
                            isStartDateEditing = false
                        }
                } else {
                    Text(measurement.start, format: Date.FormatStyle(time: .shortened))
                        .onTapGesture {
                            isStartDateEditing = true
                        }
                }
                Text("〜")
                if isEndDateEditing {
                    DatePicker(
                        "",
                        selection: $endDate,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .focused($isEndDateFocused)
                    .onChange(of: isEndDateFocused) { _, newValue in
                        if !newValue {
                            isEndDateEditing = false
                            updateMeasurement {
                                measurement.end = endDate
                            }
                        }
                    }
                    .onAppear {
                        isEndDateFocused = true
                    }
                    .onSubmit {
                        isEndDateEditing = false
                    }
                } else {
                    Text(measurement.end, format: Date.FormatStyle(time: .shortened))
                        .onTapGesture {
                            isEndDateEditing = true
                        }
                }
                Text(String(humanReadableDuration(measurement.duration)))
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(0.05))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(0)
    }

    private func humanReadableDuration(_ duration: TimeInterval) -> String {
        "\(Int(duration / 60)) m"
    }

    private func updateMeasurement(_ update: () -> Void) {
        update()
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

#Preview {
    MeasurementItem(measurement: Measurement(
        genre: "デザイン",
        work: "UIスケッチ",
        start: Date(),
        end: Date(timeInterval: 180, since: Date())
    ))
}
