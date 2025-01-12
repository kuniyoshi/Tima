import SwiftUI
import SwiftData

struct TaskList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Tima.Task]

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
    let container = try! ModelContainer(for: Tima.Task.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    context.insert(Tima.Task(name: "blue", color: .blue))
    context.insert(Tima.Task(name: "red", color: .red))
    context.insert(Tima.Task(name: "green", color: .green))

    return TaskList()
        .modelContext(context)
}
