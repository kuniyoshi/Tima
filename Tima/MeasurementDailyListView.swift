import SwiftUI
import Combine

// Represents daily measuerments
struct MeasurementDailyListView: View {
    @ObservedObject var model: MeasurementDaillyListModel

    var body: some View {
        if let first = model.head {
            HStack {
                Text(Util.date(first.start))
                    .font(.headline)
                Spacer()
            }
        }
        ForEach(model.pairs, id: \.0) { (measurement, task) in
            HStack {
                WorkItem(work: task)
                MeasurementItem(measurement: measurement, task: task)
                Button(action: {
                    model.playMeasurement(measurement)
                }) {
                    Image(systemName: "play.circle")
                }
            }
            .contentShape(Rectangle())
            .swipeActions {
                Button(role: .destructive) {
                    model.removeMeasurement(measurement)
                } label: {
                    Label("", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    let workB = Work(name: "デザインb", color: .blue)
    let workR = Work(name: "デザインr", color: .red)
    let model = MeasurementDaillyListModel(
        pairs: [
            (Measurement(
                taskName: workB.name,
                detail: "UIスケッチ",
                start: Date(timeInterval: 700, since: Date()),
                end: Date(timeInterval: 1080, since: Date())
            ), workB),
            (Measurement(
                taskName: workB.name,
                detail: "UIスケッチ",
                start: Date(),
                end: Date(timeInterval: 300, since: Date())
            ), workB),
            (Measurement(
                taskName: workR.name,
                detail: "UIスケッチ",
                start: Date(),
                end: Date(timeInterval: 300, since: Date())
            ), workR)
        ],
        onPlay: { _ in },
        onDelete: { _ in }
    )
    MeasurementDailyListView(model: model)
}
