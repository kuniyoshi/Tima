import Foundation
import SwiftData

@Model
final class Measurement {
    var genre: String
    var work: String
    var start: Date
    var end: Date

    init(genre: String, work: String, start: Date, end: Date) {
        self.genre = genre
        self.work = work
        self.start = start
        self.end = end
    }
}
