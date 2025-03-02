import SwiftUI
import SwiftData

// List view for ImageColor
struct ImageColorList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var works: [ImageColor]

    var body: some View {
        VStack {
            ForEach(works) { work in
                ImageColorItem(work: work)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: ImageColor.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)

    context.insert(ImageColor(name: "blue", color: .blue))
    context.insert(ImageColor(name: "red", color: .red))
    context.insert(ImageColor(name: "green", color: .green))

    return ImageColorList()
        .modelContext(context)
}
