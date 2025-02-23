import SwiftUI
import AppKit

class CompletionTextField: NSTextField {
    var onArrowKey: ((NSEvent) -> Void)?

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 126 || event.keyCode == 125 {
            onArrowKey?(event)
        } else {
            super.keyDown(with: event)
        }
    }
}

struct CompletionTextFieldRepresentable: NSViewRepresentable {
    @Binding private var text: String
    private let placeholder: String
    private let onArrowKey: ((NSEvent) -> Void)?

    init(_ placeholder: String, text: Binding<String>, onArrowKey: ((NSEvent) -> Void)?) {
        self.placeholder = placeholder
        self._text = text
        self.onArrowKey = onArrowKey
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = CompletionTextField()
        textField.delegate = context.coordinator
        textField.onArrowKey = onArrowKey
        textField.stringValue = text
        textField.placeholderString = placeholder
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: CompletionTextFieldRepresentable

        init(_ parent: CompletionTextFieldRepresentable) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }
    }
}

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
    var suggestions: [String] = ["asdf", "fdsa", "abcd"]
    @State var selectedIndex: Int = 0

    private var filteredSuggestions: [String] {
        Array(suggestions.filter { $0.hasPrefix(text) })
    }

    var body: some View {
        VStack {
            CompletionTextFieldRepresentable("search...", text: $text) { event in
                if event.keyCode == 126 {
                    if !filteredSuggestions.isEmpty {
                        selectedIndex = min(selectedIndex + 1, filteredSuggestions.count - 1)
                    }
                } else if event.keyCode == 125 {
                    if !filteredSuggestions.isEmpty {
                        selectedIndex = max(selectedIndex - 1, 0)
                    }
                }
            }
            .onChange(of: text) { _, newValue in
                showPopover = !newValue.isEmpty
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
                        }
                        .padding()
                    }
                }
            }
            .onSubmit {
                showPopover = false
            }
        }
    }
}

#Preview {
    CompletionView()
}
