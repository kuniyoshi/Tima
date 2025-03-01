import SwiftUI
import AppKit

// カスタムの NSTextField。矢印キーが押されたら onArrowKey にイベントを渡すわ
class CustomTextField: NSTextField {
    var onArrowKey: ((NSEvent) -> Void)?

    override func keyDown(with event: NSEvent) {
        // keyCode 126: 上矢印、125: 下矢印
        if event.keyCode == 126 || event.keyCode == 125 {
            onArrowKey?(event)
            // 必要に応じて super.keyDown を呼び出さなくてもよいわ
        } else {
            super.keyDown(with: event)
        }
    }
}

// CustomTextField を SwiftUI で使うためのラッパーだわ
struct CustomTextFieldRepresentable: NSViewRepresentable {
    @Binding var text: String
    var onArrowKey: ((NSEvent) -> Void)?

    func makeNSView(context: Context) -> CustomTextField {
        let textField = CustomTextField()
        textField.delegate = context.coordinator
        textField.stringValue = text
        textField.onArrowKey = onArrowKey
        return textField
    }

    func updateNSView(_ nsView: CustomTextField, context: Context) {
        nsView.stringValue = text
        nsView.onArrowKey = onArrowKey
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: CustomTextFieldRepresentable

        init(_ parent: CustomTextFieldRepresentable) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }
    }
}

// 使用例。TextField に入力しながら、矢印キーが押されたらメッセージを更新するわ
struct CustomTextFieldView: View {
    @State private var message = "矢印キーを押してみてね"
    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 20) {
            CustomTextFieldRepresentable(text: $text) { event in
                if event.keyCode == 126 {
                    message = "上矢印キーが押されたわ"
                } else if event.keyCode == 125 {
                    message = "下矢印キーが押されたわ"
                }
            }
            .frame(width: 300, height: 22) // TextField の高さは通常22くらいね

            Text(message)
                .padding()
        }
        .padding()
    }
}

#Preview {
    CustomTextFieldView()
}
