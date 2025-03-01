import SwiftUI
import SwiftData

// Work view
struct WorkItem: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var works: [ImageColor]

    @State private var work: ImageColor
    @State private var name: String = ""
    @State private var isNameEditing = false
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(work.color.uiColor)
                    .onTapGesture {
                        // TODO: isColorEditing
                    }
                Text(work.name)
                    .font(.headline)
                    .onTapGesture {
                        isNameEditing = true
                    }
            }
            .popover(isPresented: $isNameEditing) {
                ScrollViewReader { reader in
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack {
                            ForEach(works) { work in
                                Text(work.name)
                                    .id(work.id)
                                    .font(.headline)
                                    .background(work == self.work ? Color.secondary.opacity(0.3) : SwiftUI.Color.clear)
                                    .padding(2)
                                    .onTapGesture {
                                        self.work = work
                                        name = work.name
                                        isNameEditing = false
                                    }
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        reader.scrollTo(work.id, anchor: .center)
                    }
                }
            }
        }
    }

    init(work: ImageColor) {
        self.work = work
        self._name = State(initialValue: work.name)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ImageColor.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)

    context.insert(ImageColor(name: "blue", color: .blue))
    context.insert(ImageColor(name: "red", color: .red))
    context.insert(ImageColor(name: "green", color: .green))

    let initial = ImageColor(name: "デザイン", color: .red)

    return WorkItem(work: initial)
        .modelContainer(container)
}
