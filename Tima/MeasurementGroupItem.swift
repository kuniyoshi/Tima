import SwiftUI

struct MeasurementGroupItem: View {
    let measurements: [Measurement]

    var body: some View {
        VStack(spacing: 0) {
            if let first = measurements.first {
                Text(date(first.start))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .padding(8)
            }

            List {
                ForEach(measurements) { measurement in
                    MeasurementItem(measurement: measurement)
                }
            }
            .listStyle(.plain)
            .padding(0)
        }
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
            genre: "デザイン",
            work: "UIスケッチ",
            start: Date(timeInterval: 700, since: Date()),
            end: Date(timeInterval: 1080, since: Date())
        ),
        Measurement(
            genre: "デザイン",
            work: "UIスケッチ",
            start: Date(),
            end: Date(timeInterval: 300, since: Date())
        ),
        Measurement(
            genre: "デザイン",
            work: "UIスケッチ",
            start: Date(),
            end: Date(timeInterval: 300, since: Date())
        )
    ])
}
