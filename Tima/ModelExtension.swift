import SwiftData
import SwiftUI

extension Tima.Task {
    static func findOrCreate(name: String, in context: ModelContext) throws -> Tima.Task {
        let request = FetchDescriptor<Tima.Task>(
            predicate: #Predicate {
                $0.name == name
            }
        )

        let results = try context.fetch(request)
        assert(results.count <= 1)

        if let existing = results.first {
            return existing
        } else {
            let newTask = Tima.Task(name: name, color: .cyan) // TODO: viable
            context.insert(newTask)
            return newTask
        }
    }
}

