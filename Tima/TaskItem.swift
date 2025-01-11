import SwiftUI
import SwiftData

struct TaskItem: View {
    @State private var task: Task

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(task.color.uiColor)
            Text(task.name)
                .font(.headline)
        }
    }

    init(task: Task) {
        self.task = task
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Task.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)

    context.insert(Task(name: "blue", color: .blue))
    context.insert(Task(name: "red", color: .red))
    context.insert(Task(name: "green", color: .green))

    return TaskItem(task: Task(name: "デザイン", color: .red))
}
