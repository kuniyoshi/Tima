import Cocoa
import Foundation
import SwiftData
import UniformTypeIdentifiers

// An exporter of App's data
struct ModelExporter {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    @MainActor
    func removeAll() throws {
        let context = container.mainContext

        let imageColors = try context.fetch(FetchDescriptor<ImageColor>())
        let measurements = try context.fetch(FetchDescriptor<Measurement>())
        let timeboxes = try context.fetch(FetchDescriptor<TimeBox>())

        for imageColor in imageColors {
            context.delete(imageColor)
        }
        for measurement in measurements {
            context.delete(measurement)
        }
        for timebox in timeboxes {
            context.delete(timebox)
        }

        try context.save()
    }

    @MainActor
    func exportToJSON() throws -> URL? {
        let context = container.mainContext
        let imageColors = try context.fetch(FetchDescriptor<ImageColor>())
        let measurements = try context.fetch(FetchDescriptor<Measurement>())
        let timeBoxes = try context.fetch(FetchDescriptor<TimeBox>())

        let exportData = ExportData(imageColors: imageColors, measurements: measurements, timeBoxes: timeBoxes)

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

    @MainActor
    func importFromJSON(url: URL) throws {
        let context = container.mainContext
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(ExportData.self, from: data)

        for imageColor in decoded.imageColors {
            context.insert(imageColor)
        }
        for measurement in decoded.measurements {
            context.insert(measurement)
        }
        for timeBox in decoded.timeBoxes {
            context.insert(timeBox)
        }

        try context.save()
    }
}

private struct ExportData: Codable {
    let imageColors: [ImageColor]
    let measurements: [Measurement]
    let timeBoxes: [TimeBox]
}
