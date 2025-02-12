import SwiftUI
import SwiftData

// List view for work
struct WorkList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var works: [Work]

    var body: some View {
        VStack {
            ForEach(works) { work in
                WorkItem(work: work)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Work.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    context.insert(Work(name: "blue", color: .blue))
    context.insert(Work(name: "red", color: .red))
    context.insert(Work(name: "green", color: .green))

    return WorkList()
        .modelContext(context)
}
