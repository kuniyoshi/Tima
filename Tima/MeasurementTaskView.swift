import SwiftUI

struct MeasurementTaskView: View {
    @State private var task: MeasurementTask

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(task.color.uiColor)
            Text(task.name)
                .font(.headline)
        }
    }

    init(task: MeasurementTask) {
        self.task = task
    }
}

#Preview {
    MeasurementTaskView(task: MeasurementTask(name: "デザイン", color: TimaColor.red))
}
