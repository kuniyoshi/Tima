import SwiftUI
import SwiftData

struct TaskEditor: View {
    @State private var task: Tima.Task

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(task.color.uiColor)
            Text(task.name)
                .font(.headline)
        }
    }

    init(task: Tima.Task) {
        self.task = task
    }
}

#Preview {
    TaskEditor(task: Tima.Task(name: "デザイン", color: .red))
}


