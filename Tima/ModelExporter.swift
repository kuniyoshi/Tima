import Cocoa
import Foundation
import SwiftData
import UniformTypeIdentifiers

struct ModelExporter {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    @MainActor func exportToJSON() throws -> URL? {
        let context = container.mainContext
        let tasks = try context.fetch(FetchDescriptor<Tima.Task>())
        let measurements = try context.fetch(FetchDescriptor<Measurement>())
        let timeBoxes = try context.fetch(FetchDescriptor<TimeBox>())

        let exportData = ExportData(tasks: tasks, measurements: measurements, timeBoxes: timeBoxes)

        let json = try JSONEncoder().encode(exportData)

        let savePanel = NSSavePanel()
        savePanel.title = "Export Data"
        savePanel.allowedContentTypes = [UTType.json]
        savePanel.nameFieldStringValue = "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "ExportData").json"
        savePanel.directoryURL = FileManager.default.urls(
            for: .downloadsDirectory,
            in: .userDomainMask
        ).first

        if savePanel.runModal() == .OK, let url = savePanel.url {
            try json.write(to: url)
            return url
        }

        return nil
    }
}

private struct ExportData: Codable {
    let tasks: [Tima.Task]
    let measurements: [Measurement]
    let timeBoxes: [TimeBox]
}
