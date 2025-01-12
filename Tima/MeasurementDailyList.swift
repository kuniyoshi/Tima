import SwiftUI

// Represents daily measuerments
struct MeasurementDailyList: View, Identifiable {
    let measurements: [Measurement]
    let tasks: [Tima.Task]
    let id: Int

    init(measurements: [Measurement], tasks: [Tima.Task]) {
        self.measurements = measurements
        self.tasks = tasks
        self.id = measurements.first?.id.hashValue ?? 0
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let first = measurements.first {
                Text(Util.date(first.start))
                    .font(.headline)
            }
            ForEach(measurements) { measurement in
                if let task = tasks.first(where: { $0.id == measurement.taskID }) {
                    MeasurementItem(measurement: measurement, task: task)
                } else {
                    print("No task found for: \(measurement.taskID)")
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
                taskID: taskB.id,
                work: "UIスケッチ",
                start: Date(timeInterval: 700, since: Date()),
                end: Date(timeInterval: 1080, since: Date())
            ),
            Measurement(
                taskID: taskB.id,
                work: "UIスケッチ",
                start: Date(),
                end: Date(timeInterval: 300, since: Date())
            ),
            Measurement(
                taskID: taskR.id,
                work: "UIスケッチ",
                start: Date(),
                end: Date(timeInterval: 300, since: Date())
            )
        ],
        tasks: [taskB, taskR]
    )
}
