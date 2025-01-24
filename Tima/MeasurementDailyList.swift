import SwiftUI

// Represents daily measuerments
struct MeasurementDailyList: View, Identifiable {
    struct Callback {
        let onPlay: (Measurement) -> Void
        let onDelete: (Measurement) -> Void
    }

    let measurements: [Measurement]
    let tasks: [Tima.Task]
    let id: Int
    let callback: Callback

    init(
        measurements: [Measurement],
        tasks: [Tima.Task],
        callback: Callback
    ) {
        self.measurements = measurements
        self.tasks = tasks
        self.id = measurements.first?.id.hashValue ?? 0
        self.callback = callback
    }

    var body: some View {
        if let first = measurements.first {
            HStack {
                Text(Util.date(first.start))
                    .font(.headline)
                Spacer()
            }
        }
        ForEach(measurements) { measurement in
            if let task = tasks.first(where: { $0.name == measurement.taskName }) {
                HStack {
                    TaskItem(task: task)
                    MeasurementItem(measurement: measurement, task: task)
                    Button(action: {
                        callback.onPlay(measurement)
                    }) {
                        Image(systemName: "play.circle")
                    }
                }
                .contentShape(Rectangle())
                .swipeActions {
                    Button(role: .destructive) {
                        print("deleted")
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
    return MeasurementDailyList(
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
        tasks: [taskB, taskR],
        callback: .init(onPlay: { _ in }, onDelete: { _ in })
    )
}
