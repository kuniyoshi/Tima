import SwiftUI
import SwiftData

// List view for ImageColor
struct ImageColorList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var imageColors: [ImageColor]

    var body: some View {
        VStack {
            ForEach(imageColors) { imageColor in
                ImageColorItem(imageColor: imageColor)
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
