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
                ScrollViewReader { reader in
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack {
                            ForEach(tasks) { task in
                                Text(task.name)
                                    .id(task.id)
                                    .font(.headline)
                                    .background(task == self.task ? Color.secondary.opacity(0.3) : Color.clear)
                                    .padding(2)
                                    .onTapGesture {
                                        self.task = task
                                        name = task.name
                                        isNameEditing = false
                                    }
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        reader.scrollTo(task.id, anchor: .center)
                    }
                }
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

    let initial = Task(name: "デザイン", color: .red)

    return TaskItem(task: initial)
        .modelContainer(container)
}
