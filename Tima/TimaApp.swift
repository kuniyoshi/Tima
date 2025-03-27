import SwiftUI
import SwiftData
import Combine

// Entry point
@main
struct TimaApp: App {
    var sharedModelContainer: ModelContainer = {
        // delete `~/Library/Containers/jp.pura.Tima/Data/Library/Application\ Support/default.store` on destructive change on model
        let schema = Schema([
                                ImageColor.self,
                                Measurement.self,
                                TimeBox.self,
                            ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var showPreferences: Bool = false
    @State private var showErrorDialog: Bool = false
    @State private var errorMessage: String = ""

    private let refreshSubject = PassthroughSubject<Void, Never>()
    private let terminateSubject = PassthroughSubject<Void, Never>()

    var body: some Scene {
        WindowGroup {
            ContentView(
                database: Database(
                    modelContext: sharedModelContainer.mainContext,
                    onRefreshDate: refreshSubject.eraseToAnyPublisher()
                ),
                onRefreshDate: refreshSubject.eraseToAnyPublisher(),
                onTerminate: terminateSubject.eraseToAnyPublisher()
            )
                .alert(isPresented: $showErrorDialog) {
                    Alert(
                        title: Text("Export Error"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(after: .newItem) {
                Button("Export Data") {
                    exportData()
                }
                .keyboardShortcut("E", modifiers: [.command])

                Button("Remove All Data") {
                    exportData()
                }
            }

            CommandGroup(after: .textEditing) {
                Button("Terminate Running") {
                    terminateSubject.send()
                }
                .keyboardShortcut("T", modifiers: [.command])

                Button("Refresh Today") {
                    refreshSubject.send()
                }
                .keyboardShortcut("R", modifiers: [.command])
            }
        }

        Settings {
            SettingsView(model: .init())
        }
    }

    init() {
        UserDefaults.standard.register(defaults: [
            SettingsKeys.Notification.playSound.rawValue: SettingsDefaults.TimeBox.isSoundNotification,
            SettingsKeys.Notification.showBanner.rawValue: SettingsDefaults.TimeBox.isBannerNotification
        ])
    }

    private func exportData() {
        do {
            if let path = try ModelExporter(container: sharedModelContainer).exportToJSON() {
                print("Exported to \(path)")
            }
            errorMessage = ""
        } catch {
            print("Could not export data: \(error.localizedDescription)")
            errorMessage = "Could not export data."
            showErrorDialog = true
        }
    }

    private func removeAllData() {
        do {
            try ModelExporter(container: sharedModelContainer).removeAll()
        } catch {
            print("Could not remove all data: \(error.localizedDescription)")
            errorMessage = "Could not remove all data."
            showErrorDialog = true
        }
    }
}
