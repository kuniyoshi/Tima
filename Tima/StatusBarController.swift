import SwiftUI
import Combine
import AppKit

@MainActor
class StatusBarController {
    static let shared = StatusBarController()

    private var statusItem: NSStatusItem
    private var cancellable: AnyCancellable?

    private init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.action = #selector(didClickStatusItem)
            button.target = self
        }
    }

    func bind(to model: TimeBoxModel) {
        cancellable = model.$isStateRunning
            .receive(on: RunLoop.main)
            .sink { [weak self] isRunning in
                self?.updateIcon(isRunning: isRunning)
            }
    }

    @objc private func didClickStatusItem() {
        NSApp.activate(ignoringOtherApps: true)
    }

    private func updateIcon(isRunning: Bool) {
        if let button = statusItem.button {
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App"
            button.image = NSImage(
                systemSymbolName: isRunning ? "figure.run" : "figure.stand",
                accessibilityDescription: isRunning ? "TimeBox Running" : "TimeBox Stopped"
            )
            button.toolTip = isRunning ? "\(appName)'s TimeBox Running" : "\(appName)'s TimeBox Stopped"
        }
    }
}
