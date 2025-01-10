import SwiftUI

struct MeasurementGroupItem: View, Identifiable {
    let measurements: [Measurement]

    var body: some View {
        VStack(alignment: .leading) {
            if let first = measurements.first {
                Text(date(first.start))
                    .font(.headline)
            }
            ForEach(measurements) { measurement in
                    MeasurementItem(measurement: measurement)
            }
        }
    }

    var id: Int {
        measurements.first?.id.hashValue ?? 0
    }

    private func date(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    MeasurementGroupItem(measurements: [
        Measurement(
            task: MeasurementTask(name: "デザイン", color: TimaColor.red),
            work: "UIスケッチ",
            start: Date(timeInterval: 700, since: Date()),
            end: Date(timeInterval: 1080, since: Date())
        ),
        Measurement(
            task: MeasurementTask(name: "デザイン", color: TimaColor.blue),
            work: "UIスケッチ",
            start: Date(),
            end: Date(timeInterval: 300, since: Date())
        ),
        Measurement(
            task: MeasurementTask(name: "デザイン", color: TimaColor.cyan),
            work: "UIスケッチ",
            start: Date(),
            end: Date(timeInterval: 300, since: Date())
        )
    ])
}
