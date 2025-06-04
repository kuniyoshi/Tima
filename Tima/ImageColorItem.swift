import SwiftUI
import SwiftData

// ImageColor view
struct ImageColorItem: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var imageColors: [ImageColor]

    @State private var imageColor: ImageColor
    @State private var name: String = ""
    @State private var isNameEditing = false
    @State private var searchText: String = ""
    @State private var selectedIndex: Int = 0
    @FocusState private var isNameFocused: Bool
    @FocusState private var isSearchFocused: Bool

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
                VStack(spacing: 0) {
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search work...", text: $searchText)
                            .textFieldStyle(.plain)
                            .focused($isSearchFocused)
                            .onSubmit {
                                if filteredImageColors.count == 1 {
                                    selectWork(filteredImageColors[0])
                                } else {
                                    selectCurrentItem()
                                }
                            }
                            .onKeyPress(keys: [.upArrow, .downArrow, .escape]) { press in
                                return handleKeyPress(press)
                            }
                    }
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor))
                    
                    Divider()
                    
                    // Filtered list
                    ScrollViewReader { reader in
                        ScrollView(.vertical, showsIndicators: true) {
                            VStack(spacing: 2) {
                                ForEach(Array(filteredImageColors.enumerated()), id: \.element.id) { index, work in
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .foregroundColor(work.color.uiColor)
                                            .font(.caption)
                                        Text(work.name)
                                            .font(.headline)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(backgroundForItem(work: work, index: index))
                                    .cornerRadius(4)
                                    .id(work.id)
                                    .onTapGesture {
                                        selectWork(work)
                                    }
                                }
                            }
                            .padding(4)
                        }
                        .frame(minHeight: 200, maxHeight: 400)
                        .onAppear {
                            searchText = ""
                            isSearchFocused = true
                            if let currentIndex = filteredImageColors.firstIndex(where: { $0.id == imageColor.id }) {
                                selectedIndex = currentIndex
                                reader.scrollTo(imageColor.id, anchor: .center)
                            }
                        }
                        .onChange(of: selectedIndex) { _, newValue in
                            if newValue >= 0 && newValue < filteredImageColors.count {
                                reader.scrollTo(filteredImageColors[newValue].id, anchor: .center)
                            }
                        }
                    }
                }
                .frame(width: 300)
            }
        }
    }

    init(imageColor: ImageColor) {
        self.imageColor = imageColor
        self._name = State(initialValue: imageColor.name)
    }
    
    // Computed property for filtered results
    private var filteredImageColors: [ImageColor] {
        if searchText.isEmpty {
            return imageColors
        } else {
            return imageColors.filter { work in
                work.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Background color for list items
    private func backgroundForItem(work: ImageColor, index: Int) -> Color {
        if work == self.imageColor {
            return Color.accentColor.opacity(0.3)
        } else if index == selectedIndex {
            return Color.secondary.opacity(0.2)
        } else {
            return Color.clear
        }
    }
    
    // Select a work item
    private func selectWork(_ work: ImageColor) {
        self.imageColor = work
        name = work.name
        isNameEditing = false
    }
    
    // Select current highlighted item
    private func selectCurrentItem() {
        if selectedIndex >= 0 && selectedIndex < filteredImageColors.count {
            selectWork(filteredImageColors[selectedIndex])
        }
    }
    
    // Handle keyboard navigation
    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .upArrow:
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
        case .downArrow:
            if selectedIndex < filteredImageColors.count - 1 {
                selectedIndex += 1
            }
        case .return:
            selectCurrentItem()
        case .escape:
            isNameEditing = false
        default:
            break
        }
        return .handled
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
