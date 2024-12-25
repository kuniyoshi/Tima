import Foundation
import SwiftData

struct ModelExporter {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    @MainActor func exportToJSON() throws -> URL {
        let context = container.mainContext
        let measurements = try context.fetch(FetchDescriptor<Measurement>())
        let timeBoxes = try context.fetch(FetchDescriptor<TimeBox>())

        let exportData = ExportData(measurements: measurements, timeBoxes: timeBoxes)

        let json = try JSONEncoder().encode(exportData)

        let temporaryDirectory = FileManager.default.temporaryDirectory
        let exportFileURL = temporaryDirectory.appendingPathComponent("ExportData").appendingPathExtension("json")
        try json.write(to: exportFileURL)

        return exportFileURL
    }
}

struct ExportData: Codable {
    let measurements: [Measurement]
    let timeBoxes: [TimeBox]
}
