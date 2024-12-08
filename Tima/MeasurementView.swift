import SwiftUI

struct MeasurementView: View {
    let measurement: Measurement

    var body: some View {
        HStack {
            Text(measurement.group)
            Text(measurement.work)
            Text(measurement.start, format: Date.FormatStyle(time: .shortened))
            Text(measurement.end, format: Date.FormatStyle(time: .shortened))
        }
        .padding()
    }
}

#Preview {
    MeasurementView(measurement: Measurement(
        group: "デザイン",
        work: "UIスケッチ",
        start: Date(),
        end: Date(timeInterval: 180, since: Date())
    ))
}
