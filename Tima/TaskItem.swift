import SwiftUI
import SwiftData

struct TaskItem: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]

    @State private var task: Task
    @State private var name: String = ""
    @State private var isNameEditing = false
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(task.color.uiColor)
                Text(task.name)
                    .font(.headline)
                    .onTapGesture {
                        isNameEditing = true
                    }
            }
            .popover(isPresented: $isNameEditing) {
                VStack {
                    ForEach(tasks) { task in
                        Text(task.name)
                            .font(.headline)
                            .onTapGesture {
                                self.task = task
                                name = task.name
                                isNameEditing = false
                            }
                    }
                }
                .padding()
            }
        }
    }

    init(task: Task) {
        self.task = task
        self._name = State(initialValue: task.name)
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
        .modelContainer(container)
}
