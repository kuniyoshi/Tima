import SwiftUI

// Shows Measurement, and it can edit
struct MeasurementItemView: View {
    @Environment(\.modelContext) private var context
    private var measurement: Measurement

    private var task: Work // TODO: rename
    @State private var work: String
    @State private var startDate: Date
    @State private var endDate: Date

    @State private var isTaskEditing = false
    @State private var isWorkEditing = false
    @State private var isStartDateEditing = false
    @State private var isEndDateEditing = false

    @FocusState private var isTaskFocused: Bool
    @FocusState private var isWorkFocused: Bool
    @FocusState private var isStartDateFocused: Bool
    @FocusState private var isEndDateFocused: Bool

    @StateObject private var model: MeasurementItemModel

    init(model: MeasurementItemModel, measurement: Measurement, task: Work) {
        _model = .init(wrappedValue: model)
        self.measurement = measurement
        self.task = task
        self._work = State(initialValue: measurement.detail)
        self._startDate = State(initialValue: measurement.start)
        self._endDate = State(initialValue: measurement.end)
    }

    var body: some View {
        HStack {
            if isWorkEditing {
                TextField(work, text: $work)
                .focused($isWorkFocused)
                .onAppear {
                    isWorkFocused = true
                }
                .onSubmit {
                    isWorkEditing = false
                    context.update {
                        measurement.detail = work // TODO: need trim by robust way
                    }
                }
            } else {
                Text(measurement.detail)
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
                        .submitLabel(.done)
                        .onChange(of: isStartDateFocused) { _, newValue in
                            if !newValue {
                                isStartDateEditing = false
                                context.update {
                                    measurement.start = startDate
                                }
                            }
                        }
                        .onAppear {
                            isStartDateFocused = true
                        }
                } else {
                    Text(measurement.start, format: Date.FormatStyle(time: .shortened))
                        .foregroundColor(.primary.opacity(0.6))
                        .onTapGesture {
                            isStartDateEditing = true
                        }
                }
                Text("〜")
                    .foregroundColor(.primary.opacity(0.6))
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
                            context.update {
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
                        .foregroundColor(.primary.opacity(0.6))
                        .onTapGesture {
                            isEndDateEditing = true
                        }
                }
                Text(String(Util.humanReadableDuration(measurement.duration)))
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.primary.opacity(0.05))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(0)
    }
}

#Preview {
    let work = Work(name: "デザイン", color: .blue)
    let measurement = Measurement(
        work: work.name,
        detail: "UIスケッチ",
        start: Date(),
        end: Date(timeInterval: 180, since: Date())
    )

    MeasurementItemView(
        model: MeasurementItemModel(measurement: measurement),
        measurement: measurement,
        task: work
    )
}
