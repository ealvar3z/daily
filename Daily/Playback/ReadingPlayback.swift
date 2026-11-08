import Foundation
import Observation

@MainActor @Observable
final class ReadingPlayback {
    static let speeds = [0.75, 1.0, 1.25, 1.5, 2.0]
    let starts: [Double]
    let duration: Double
    private(set) var position: Double = 0
    private(set) var speed: Double = 1
    private(set) var isPlaying = false
    private var anchor: ContinuousClock.Instant?

    init(durations: [Double]) {
        precondition(!durations.isEmpty)
        precondition(durations.allSatisfy { $0.isFinite && $0 > 0 })
        var total = 0.0
        starts = durations.map { value in
            defer { total += value }
            return total
        }
        duration = total
    }

    var index: Int { starts.lastIndex(where: { $0 <= position }) ?? 0 }
    var isFinished: Bool { position >= duration }

    func play(now: ContinuousClock.Instant = ContinuousClock().now) {
        guard !isPlaying else { return }
        if isFinished { position = 0 }
        isPlaying = true
        anchor = now
    }

    func pause(now: ContinuousClock.Instant = ContinuousClock().now) {
        tick(now: now)
        isPlaying = false
        anchor = nil
    }

    func setSpeed(_ value: Double,
                  now: ContinuousClock.Instant = ContinuousClock().now) {
        guard Self.speeds.contains(value) else { return }
        tick(now: now)
        speed = value
    }

    func seek(to value: Double,
              now: ContinuousClock.Instant = ContinuousClock().now) {
        guard value.isFinite else { return }
        position = min(max(0, value), duration)
        if isFinished { isPlaying = false }
        anchor = isPlaying ? now : nil
    }

    func tick(now: ContinuousClock.Instant = ContinuousClock().now) {
        guard isPlaying, let previous = anchor else { return }
        let elapsed = previous.duration(to: now).components
        let seconds = Double(elapsed.seconds)
            + Double(elapsed.attoseconds) / 1e18
        guard seconds >= 0 else { return }
        position = min(duration, position + seconds * speed)
        anchor = now
        if isFinished {
            isPlaying = false
            anchor = nil
        }
    }
}
