import SwiftUI
import SwiftData

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
    let container = try! ModelContainer(
        for: MeasurementTask.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)

    context.insert(MeasurementTask(name: "blue", color: .blue))
    context.insert(MeasurementTask(name: "red", color: .red))
    context.insert(MeasurementTask(name: "green", color: .green))

    return MeasurementTaskView(task: MeasurementTask(name: "デザイン", color: .red))
}
