import SwiftUI
import Combine

// Represents daily measuerments
struct MeasurementDailyListView: View {
    @ObservedObject var model: MeasurementDaillyListModel
    let tasks: [Tima.Task]

    var body: some View {
        if let first = model.head {
            HStack {
                Text(Util.date(first.start))
                    .font(.headline)
                Spacer()
            }
        }
        ForEach(model.measurements) { measurement in
            if let task = tasks.first(where: { $0.name == measurement.taskName }) {
                HStack {
                    TaskItem(task: task)
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
            } else {
                Text("Task not found for \(String(describing: measurement.taskName)).")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    let taskB = Tima.Task(name: "デザインb", color: .blue)
    let taskR = Tima.Task(name: "デザインr", color: .red)
    let model = MeasurementDaillyListModel(
        measurements: [
            Measurement(
                taskName: taskB.name,
                work: "UIスケッチ",
                start: Date(timeInterval: 700, since: Date()),
                end: Date(timeInterval: 1080, since: Date())
            ),
            Measurement(
                taskName: taskB.name,
                work: "UIスケッチ",
                start: Date(),
                end: Date(timeInterval: 300, since: Date())
            ),
            Measurement(
                taskName: taskR.name,
                work: "UIスケッチ",
                start: Date(),
                end: Date(timeInterval: 300, since: Date())
            )
        ],
        onPlay: { _ in },
        onDelete: { _ in }
    )
    MeasurementDailyListView(model: model, tasks: [taskB, taskR])
}
