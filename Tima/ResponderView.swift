import SwiftUI
import AppKit

// NSViewのサブクラス。矢印キーの入力を検知するためにkeyDownをオーバーライドするわ。
class KeyCaptureView: NSView {
    // 矢印キーが押された時のコールバック
    var onArrowKey: ((NSEvent) -> Void)?

    // キーイベントを受け取るためにファーストレスポンダーを許可するわ
    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        // keyCode 126: 上矢印、125: 下矢印
        if event.keyCode == 126 || event.keyCode == 125 {
            onArrowKey?(event)
        } else {
            super.keyDown(with: event)
        }
    }

    // ウィンドウに追加されたら自動的にファーストレスポンダーになるようにするわ
    override func viewDidMoveToWindow() {
        window?.makeFirstResponder(self)
    }
}

// SwiftUIとNSViewを接続するためのラッパー
struct KeyCaptureViewRepresentable: NSViewRepresentable {
    var onArrowKey: ((NSEvent) -> Void)?

    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.onArrowKey = onArrowKey
        return view
    }

    func updateNSView(_ nsView: KeyCaptureView, context: Context) {
        nsView.onArrowKey = onArrowKey
    }
}

// 使用例：矢印キーが押されたらテキストを更新するView
struct ResponderView: View {
    @State private var message = "矢印キーを押してみてね"

    var body: some View {
        VStack {
            Text(message)
                .padding()
            KeyCaptureViewRepresentable { event in
                if event.keyCode == 126 {
                    message = "上矢印キーが押されたわ"
                } else if event.keyCode == 125 {
                    message = "下矢印キーが押されたわ"
                }
            }
            .frame(width: 300, height: 200)
//            .border(Color.blue)
        }
        .padding()
    }
}

#Preview {
    ResponderView()
}
