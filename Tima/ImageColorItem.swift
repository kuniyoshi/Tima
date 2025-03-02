import SwiftUI
import SwiftData

// ImageColor view
struct ImageColorItem: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var imageColors: [ImageColor]

    @State private var imageColor: ImageColor
    @State private var name: String = ""
    @State private var isNameEditing = false
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(imageColor.color.uiColor)
                    .onTapGesture {
                        // TODO: isColorEditing
                    }
                Text(imageColor.name)
                    .font(.headline)
                    .onTapGesture {
                        isNameEditing = true
                    }
            }
            .popover(isPresented: $isNameEditing) {
                ScrollViewReader { reader in
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack {
                            ForEach(imageColors) { work in
                                Text(work.name)
                                    .id(work.id)
                                    .font(.headline)
                                    .background(work == self.imageColor ? Color.secondary.opacity(0.3) : SwiftUI.Color.clear)
                                    .padding(2)
                                    .onTapGesture {
                                        self.imageColor = work
                                        name = work.name
                                        isNameEditing = false
                                    }
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        reader.scrollTo(imageColor.id, anchor: .center)
                    }
                }
            }
        }
    }

    init(imageColor: ImageColor) {
        self.imageColor = imageColor
        self._name = State(initialValue: imageColor.name)
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

    return ImageColorItem(imageColor: initial)
        .modelContainer(container)
}
