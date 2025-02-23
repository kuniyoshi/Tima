import SwiftUI
import AppKit

struct NSTextFieldView: NSViewRepresentable {
    typealias NSViewType = NSTextField

    @Binding private var text: String
    private let placeholder: String


    init(_ placeholder: String, text: Binding<String>) {
        self._text = text
        self.placeholder = placeholder
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(frame: NSRect.zero)
        textField.delegate = context.coordinator
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
        var parent: NSTextFieldView

        init(_ parent: NSTextFieldView) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }
    }
}

import SwiftUI

struct RepresentableView: View {
    @State var text: String = "Hello"

    var body: some View {
        VStack {
            NSTextFieldView("World", text: $text)
                .padding()
            TextField("World", text: $text)
                .padding()
        }
    }
}

#Preview {
    RepresentableView()
}