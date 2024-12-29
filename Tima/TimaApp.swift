import SwiftUI
import SwiftData

@main
struct TimaApp: App {
    var sharedModelContainer: ModelContainer = {
#if DEBUG
        // モデルコンテナに破壊的な変更が入ったときに削除するためのコード
        func clearPersistentStore() {
            let fileManager = FileManager.default
            if let persistentStoreURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let storeURL = persistentStoreURL.appendingPathComponent("default.store")
                do {
                    if fileManager.fileExists(atPath: storeURL.path) {
                        try fileManager.removeItem(at: storeURL)
                    }
                } catch {
                    print("Could not clear persistent store: \(error)")
                }
            }
        }

//        clearPersistentStore()
#endif

        let schema = Schema([
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

    var body: some Scene {
        WindowGroup {
            ContentView()
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
            }
        }

        Settings {
            SettingsView()
        }
    }

    init() {
        UserDefaults.standard.register(defaults: [
            SettingsKeys.TimeBox.isSoundNotification.rawValue: SettingsDefaults.TimeBox.isSoundNotification,
            SettingsKeys.TimeBox.isBannerNotification.rawValue: SettingsDefaults.TimeBox.isBannerNotification
        ])
    }

    private func exportData() {
        do {
            if let path = try ModelExporter(container: sharedModelContainer).exportToJSON() {
                print("### export to \(path)")
            }
            errorMessage = ""
        } catch {
            print("Could not export data: \(error.localizedDescription)")
            errorMessage = "Could not export data."
            showErrorDialog = true
        }
    }
}
