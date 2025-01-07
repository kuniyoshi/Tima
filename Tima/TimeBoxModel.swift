import SwiftUI
import AVFoundation

class TimeBoxModel: ObservableObject {
    enum RunningState: String {
        case ready = "hourglass.bottomhalf.filled"
        case running = "hourglass"
        case finished = "hourglass.tophalf.filled"

        func progressed() -> RunningState {
            switch self {
                case .ready: return .running
                case .running: return .finished
                case .finished: return .ready
            }
        }
    }

    enum QueryType {
        case Auto
        case Button
    }

    struct Transition {
        var state: RunningState
        var queryType: QueryType
    }

    @Published var runningState = RunningState.ready
    @Published var beganAt: Date?
    @Published var endAt: Date?
    @Published var remainingTime: String = "00:00"
    @Published var audioPlayer: AVAudioPlayer? // TODO: 通知にでならせないのかどうか
    @Published var transition: Transition?
}
