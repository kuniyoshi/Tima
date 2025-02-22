import SwiftUI
import SwiftData

// Entry point
@main
struct TimaApp: App {
    var sharedModelContainer: ModelContainer = {
        // delete `~/Library/Containers/jp.pura.Tima/Data/Library/Application\ Support/default.store` on destructive change on model
        let schema = Schema([
                                Work.self,
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
            CompletionView()
//            ContentView(database: Database(modelContext: sharedModelContainer.mainContext))
//                .alert(isPresented: $showErrorDialog) {
//                    Alert(
//                        title: Text("Export Error"),
//                        message: Text(errorMessage),
//                        dismissButton: .default(Text("OK"))
//                    )
//                }
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
            SettingsView(model: .init())
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
                print("Exported to \(path)")
            }
            errorMessage = ""
        } catch {
            print("Could not export data: \(error.localizedDescription)")
            errorMessage = "Could not export data."
            showErrorDialog = true
        }
    }
}
