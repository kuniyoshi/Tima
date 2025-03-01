import Combine
import SwiftUI
import AppKit

extension String {
    func fuzzyMatch(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        var index = query.startIndex
        for char in self {
            if char == query[index] {
                index = query.index(after: index)
                if index == query.endIndex {
                    return true
                }
            }
        }
        return false
    } // TODO: add score
}

struct ListItem: View { // TODO: move to a file
    @State var text: String
    @State var isSelected: Bool
    private var onTap: () -> Void

    var body: some View {
        Text(text)
            .foregroundColor(isSelected ? .accentColor : .secondary)
            .background(isSelected ? Color.secondary.opacity(0.2) : SwiftUI.Color.clear)
            .onTapGesture {
                onTap()
            }
    }

    init(isSelected: Bool, text: String, onTap: @escaping () -> Void) {
        self.isSelected = isSelected
        self.text = text
        self.onTap = onTap
    }
}

class CompletionModel: ObservableObject {
    struct Suggestion: Hashable {
        let text: String
        let isSelected: Bool

        init(_ text: String, _ isSelected: Bool) {
            self.text = text
            self.isSelected = isSelected
        }
    }

    @Published private(set) var suggestions: [Suggestion] = []
    @Published private(set) var selectedIndex: Int = 0
    @Published var text: String = ""
    private var works: [String]
    private var cancellables = Set<AnyCancellable>()

    var hasSuggestion: Bool {
        !text.isEmpty && suggestions.count > 0 && !(suggestions.count == 1 && text == suggestions[0].text)
    }

    var selectoin: String {
        suggestions[selectedIndex].text
    }

    init(works: [String]) {
        assert(Set(works).count == works.count)
        self.works = works
        Publishers.CombineLatest($text, $selectedIndex).map { text, selectedIndex in
            Array(self.works.filter { $0.fuzzyMatch(text) })
                .enumerated()
                .map { index, work in Suggestion(work, index == selectedIndex) }
        }
        .sink { [weak self] newValue in
            guard let self = self else { return }
            self.suggestions = newValue
        }
        .store(in: &cancellables)
    }

    func decrementSelection() {
        selectedIndex = max(selectedIndex - 1, 0)
    }

    func incrementSelection() {
        selectedIndex = min(selectedIndex + 1, suggestions.count - 1)
    }
}

struct CompletionView: View {
    @State private var text: String = ""
    @State private var showSuggestion: Bool = false
    @FocusState private var isFocused: Bool
    @ObservedObject private var model: CompletionModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                TextField("work...", text: $text)
                    .focused($isFocused)
                    .onChange(of: text) { _, newValue in
                        model.text = newValue
                        showSuggestion = model.hasSuggestion
                    }
                    .onSubmit {
                        if showSuggestion {
                            text = model.selectoin
                        }
                        showSuggestion = false
                    }
            }
            .overlay { // TODO: move to root
                Button("HIDDEN for shortcut") {
                    if isFocused {
                        model.decrementSelection()
                    }
                }
                .hidden()
                .keyboardShortcut(.upArrow, modifiers: [])

                Button("HIDDEN for shortcut") {
                    if isFocused {
                        model.incrementSelection()
                    }
                }
                .hidden()
                .keyboardShortcut(.downArrow, modifiers: [])

                Button("HIDDEN for shortcut") {
                    showSuggestion = false
                    if isFocused {
                        NSApplication.shared.keyWindow?.makeFirstResponder(nil)
                    }
                }
                .hidden()
                .keyboardShortcut(.escape, modifiers: [])
            }
            .overlay {
                Group {
                    if showSuggestion {
                        GeometryReader { geometry in
                            VStack(alignment: .leading, spacing: 0) {
                                List {
                                    ForEach(model.suggestions, id: \.self) { suggestion in
                                        ListItem(
                                            isSelected: suggestion.isSelected,
                                            text: suggestion.text,
                                            onTap: {
                                                text = suggestion.text
                                                showSuggestion = false
                                            }
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                                .id(model.selectedIndex)
                            }
                            .frame(width: 300, height: 200)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .padding(.top, 5)
                            .position(x: geometry.size.width / 2, y: 120)
                        }
                    }
                }
            }
        }
    }

    init(model: CompletionModel) {
        self.model = model
    }
}

#Preview {
    CompletionView(model: CompletionModel(works: ["asdf", "fdsa", "xyz"]))
}
