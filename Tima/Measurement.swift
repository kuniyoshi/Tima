import Foundation
import SwiftData

@Model
final class Measurement {
    var group: String
    var work: String
    var start: Date
    var end: Date

    init(group: String, work: String, start: Date, end: Date?) {
        self.group = group
        self.work = work
        self.start = start
        self.end = end ?? start
    }
}
