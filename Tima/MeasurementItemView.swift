import SwiftUI

// Shows Measurement, and it can edit
struct MeasurementItemView: View {
    @State private var work: String
    @State private var startDate: Date
    @State private var endDate: Date

    @State private var isWorkEditing = false
    @State private var isStartDateEditing = false
    @State private var isEndDateEditing = false

    @FocusState private var isWorkFocused: Bool
    @FocusState private var isStartDateFocused: Bool
    @FocusState private var isEndDateFocused: Bool

    @StateObject private var model: MeasurementItemModel

    init(_ model: MeasurementItemModel) {
        _model = .init(wrappedValue: model)
        self._work = State(initialValue: model.measurement.detail)
        self._startDate = State(initialValue: model.measurement.start)
        self._endDate = State(initialValue: model.measurement.end)
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
                    model.updateDetail(work)
                }
            } else {
                Text(model.measurement.detail)
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
                                model.updateStartDate(startDate)
                            }
                        }
                        .onAppear {
                            isStartDateFocused = true
                        }
                } else {
                    Text(model.measurement.start, format: Date.FormatStyle(time: .shortened))
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
                            model.updateEndDate(endDate)
                        }
                    }
                    .onAppear {
                        isEndDateFocused = true
                    }
                    .onSubmit {
                        isEndDateEditing = false
                    }
                } else {
                    Text(model.measurement.end, format: Date.FormatStyle(time: .shortened))
                        .foregroundColor(.primary.opacity(0.6))
                        .onTapGesture {
                            isEndDateEditing = true
                        }
                }
                Text(String(Util.humanReadableDuration(model.measurement.duration)))
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

    MeasurementItemView(MeasurementItemModel(measurement, onUpdate: { _ in }))
}
