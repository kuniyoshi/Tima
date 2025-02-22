import SwiftUI

struct CompletionView: View {
    @State var text: String = ""
    @State private var showPopover: Bool = false
    var suggestions: [String] = ["asdf", "fdsa", "qwer"]

    var body: some View {
        VStack {
            TextField("Enter text...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: text) { _, newValue in
                    showPopover = !newValue.isEmpty
                }
                .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                    VStack(alignment: .leading) {
                        ForEach(suggestions.filter { $0.hasPrefix(text)}, id: \.self) { suggestion in
                            Text(suggestion)
                                .onTapGesture {
                                    text = suggestion
                                    showPopover = false
                                }
                        }
                    }
                }
                .onSubmit {
                    showPopover = false
                }
        }
        Text("CompletionView")
    }
}

