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
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var showPreferences: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(HiddenTitleBarWindowStyle())

        Settings {
            SettingsView()
        }
    }

    init() {
        UserDefaults.standard.register(defaults: [
            UserDefaultsKeys.notificationWithSound.rawValue: true,
            UserDefaultsKeys.notificationFromCenter.rawValue: true
        ])
    }
}
