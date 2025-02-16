import SwiftData
import SwiftUI

extension Work {
    static func findOrCreate(name: String, in context: ModelContext) throws -> Work {
        let request = FetchDescriptor<Work>(
            predicate: #Predicate {
                $0.name == name
            }
        )

        let results = try context.fetch(request)
        assert(results.count <= 1)

        if let existing = results.first {
            return existing
        } else {
            let newTask = Work(name: name, color: .random)
            context.insert(newTask)
            return newTask
        }
    }
}
