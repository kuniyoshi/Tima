import SwiftUI

struct MeasurementItem: View {
    let measurement: Measurement

    var body: some View {
        HStack {
            Text(measurement.genre)
            Text(measurement.work)
            Text(measurement.start, format: Date.FormatStyle(time: .shortened))
            Text(measurement.end, format: Date.FormatStyle(time: .shortened))
        }
        .padding(0)
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
