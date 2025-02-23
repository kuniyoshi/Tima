import SwiftUI
import AppKit

struct ListItem: View {
    @State var text: String
    @State var isSelected: Bool
    private var onTap: () -> Void

    var body: some View {
        Text(text)
            .foregroundColor(isSelected ? .accentColor : .secondary)
            .background(isSelected ? SwiftUI.Color.secondary.opacity(0.2) : SwiftUI.Color.clear)
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

struct CompletionView: View {
    @State var text: String = ""
    @State private var showPopover: Bool = false
    @State var selectedIndex: Int = 0
    private var suggestions: [String] = ["asdf", "fdsa", "abcd"]

    private var filteredSuggestions: [String] {
        Array(suggestions.filter { $0.hasPrefix(text) })
    }

    var body: some View {
        VStack {
            TextField("work...", text: $text)
            .onChange(of: text) { _, newValue in
                showPopover = !newValue.isEmpty && filteredSuggestions.count > 0
            }
            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                VStack(alignment: .leading) {
                    List {
                        ForEach(Array(filteredSuggestions.enumerated()), id: \.element) { index, suggestion in
                            ListItem(
                                isSelected: index == selectedIndex,
                                text: suggestion,
                                onTap: {
                                    text = suggestion
                                    showPopover = false
                                }
                            )
                            .padding()
                        }
                    }
                }
                .id(selectedIndex)
            }
            .onSubmit {
                showPopover = false
            }

            Button("HIDDEN for shortcut") {
                if showPopover {
                    text = filteredSuggestions[selectedIndex]
                }
                showPopover = false
            }
            .hidden()
            .keyboardShortcut(.return, modifiers: [])

            Button("HIDDEN for shortcut") {
                showPopover = false
            }
            .hidden()
            .keyboardShortcut(.escape, modifiers: [])

            Button("HIDDEN for shortcut") {
                print("### selectedIndex: \(selectedIndex)")
                if showPopover {
                    selectedIndex = min(selectedIndex + 1, filteredSuggestions.count - 1)
                }
                print("--- selectedIndex: \(selectedIndex)")
            }
            .hidden()
            .keyboardShortcut(.downArrow, modifiers: [])

            Button("HIDDEN for shortcut") {
                print("### selectedIndex: \(selectedIndex)")
                if showPopover {
                    selectedIndex = max(selectedIndex - 1, 0)
                }
                print("--- selectedIndex: \(selectedIndex)")
            }
            .hidden()
            .keyboardShortcut(.upArrow, modifiers: [])
        }
    }
}

#Preview {
    CompletionView()
}
