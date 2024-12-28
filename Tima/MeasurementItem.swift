import SwiftUI

struct MeasurementItem: View {
    let measurement: Measurement

    var body: some View {
        HStack {
            Text(measurement.genre)
                .foregroundColor(.primary)
            Text(measurement.work)

            Spacer()

            HStack {
                Text(measurement.start, format: Date.FormatStyle(time: .shortened))
                Text("〜")
                Text(measurement.end, format: Date.FormatStyle(time: .shortened))
                Text(String(humanReadableDuration(measurement.duration)))
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(0.05))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(0)
    }

    private func humanReadableDuration(_ duration: TimeInterval) -> String {
        "\(Int(duration / 60)) m"
    }
}

#Preview {
    MeasurementItem(measurement: Measurement(
        genre: "デザイン",
        work: "UIスケッチ",
        start: Date(),
        end: Date(timeInterval: 180, since: Date())
    ))
}
