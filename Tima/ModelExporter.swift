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
        let measurements = try context.fetch(FetchDescriptor<Measurement>())
        let timeBoxes = try context.fetch(FetchDescriptor<TimeBox>())

        let exportData = ExportData(measurements: measurements, timeBoxes: timeBoxes)

        let json = try JSONEncoder().encode(exportData)

        let savePanel = NSSavePanel()
        savePanel.title = "Export Data"
        savePanel.allowedContentTypes = [UTType.json]
        savePanel.nameFieldStringValue = "ExportData.json"
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
    let measurements: [Measurement]
    let timeBoxes: [TimeBox]
}
