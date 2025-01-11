import SwiftUI
import SwiftData

struct TaskList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]

    var body: some View {
        VStack {
            ForEach(tasks) { task in
                TaskItem(task: task)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Task.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    context.insert(Task(name: "blue", color: .blue))
    context.insert(Task(name: "red", color: .red))
    context.insert(Task(name: "green", color: .green))

    return TaskList()
        .modelContext(context)
}
