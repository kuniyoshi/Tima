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
        ForEach(model.pairs, id: \.0.measurement) { (itemModel, task) in
            HStack {
                WorkItem(work: task)
                MeasurementItemView(itemModel)
                Button(action: {
                    model.playMeasurement(itemModel.measurement)
                }) {
                    Image(systemName: "play.circle")
                }
            }
            .contentShape(Rectangle())
            .swipeActions {
                Button(role: .destructive) {
                    model.removeMeasurement(itemModel.measurement)
                } label: {
                    Label("", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    let workB = ImageColor(name: "デザインb", color: .blue)
    let workR = ImageColor(name: "デザインr", color: .red)
    let model = MeasurementDaillyListModel(
        pairs: [
            (MeasurementItemModel(Measurement(
                work: workB.name,
                detail: "UIスケッチ",
                start: Date(timeInterval: 700, since: Date()),
                end: Date(timeInterval: 1080, since: Date())
            ), onUpdate: { _ in }), workB),
            (MeasurementItemModel(Measurement(
                work: workB.name,
                detail: "UIスケッチ",
                start: Date(),
                end: Date(timeInterval: 300, since: Date())
            ), onUpdate: { _ in }), workB),
            (MeasurementItemModel(Measurement(
                work: workR.name,
                detail: "UIスケッチ",
                start: Date(),
                end: Date(timeInterval: 300, since: Date())
            ), onUpdate: { _ in }), workR)
        ],
        onPlay: { _ in },
        onDelete: { _ in }
    )
    MeasurementDailyListView(model: model)
}
