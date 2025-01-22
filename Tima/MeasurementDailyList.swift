import SwiftUI

// Represents daily measuerments
struct MeasurementDailyList: View, Identifiable {
    let measurements: [Measurement]
    let tasks: [Tima.Task]
    let id: Int
    let callback: (Measurement) -> Void

    init(
        measurements: [Measurement],
        tasks: [Tima.Task],
        callback: @escaping (Measurement) -> Void
    ) {
        self.measurements = measurements
        self.tasks = tasks
        self.id = measurements.first?.id.hashValue ?? 0
        self.callback = callback
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let first = measurements.first {
                Text(Util.date(first.start))
                    .font(.headline)
            }
            ForEach(measurements) { measurement in
                if let task = tasks.first(where: { $0.name == measurement.taskName }) {
                    HStack {
                        TaskItem(task: task)
                        MeasurementItem(measurement: measurement, task: task)
                        Button(action: {
                            callback(measurement)
                        }) {
                            Image(systemName: "play.circle")
                        }
                    }
                } else {
                    Text("Task not found for \(String(describing: measurement.taskName)).")
                        .foregroundColor(.red)
                }
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
        callback: { _ in }
    )
}
