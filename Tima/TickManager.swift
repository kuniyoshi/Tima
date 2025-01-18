import Foundation

actor TickManager {
    static let shared = TickManager()
    private var timer: DispatchSourceTimer?

    func setTimer(interval: TimeInterval, onTick: @escaping @Sendable () -> Void) {
        timer?.cancel()
        let newTimer = DispatchSource.makeTimerSource(queue: .global())
        newTimer.schedule(deadline: .now() + interval, repeating: interval)
        newTimer.setEventHandler(handler: onTick)
        newTimer.resume()
        timer = newTimer
    }
}
