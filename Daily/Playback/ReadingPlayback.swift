import Foundation
import Observation

@MainActor @Observable
final class ReadingPlayback {
    static let speeds = [0.75, 1.0, 1.25, 1.5, 2.0]
    let starts: [Double]
    let duration: Double
    let reflectionIndices: Set<Int>
    private(set) var position: Double = 0
    private(set) var speed: Double = 1
    private(set) var isPlaying = false
    private var anchor: ContinuousClock.Instant?

    init(durations: [Double], reflectionIndices: Set<Int> = []) {
        precondition(!durations.isEmpty)
        precondition(durations.allSatisfy { $0.isFinite && $0 > 0 })
        precondition(reflectionIndices.allSatisfy { durations.indices.contains($0) })
        self.reflectionIndices = reflectionIndices
        var total = 0.0
        starts = durations.map { value in
            defer { total += value }
            return total
        }
        duration = total
    }

    var index: Int { starts.lastIndex(where: { $0 <= position }) ?? 0 }
    var isFinished: Bool { position >= duration }
    var isWaitingForReflection: Bool {
        !isPlaying && !isFinished && reflectionIndices.contains(index)
    }

    func play(now: ContinuousClock.Instant = ContinuousClock().now) {
        guard !isPlaying else { return }
        if isFinished { position = 0 }
        if reflectionIndices.contains(index) {
            position = index + 1 < starts.count ? starts[index + 1] : duration
            if isFinished { return }
        }
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
        if isFinished || reflectionIndices.contains(index) { isPlaying = false }
        anchor = isPlaying ? now : nil
    }

    func tick(now: ContinuousClock.Instant = ContinuousClock().now) {
        guard isPlaying, let previous = anchor else { return }
        let elapsed = previous.duration(to: now).components
        let seconds = Double(elapsed.seconds)
            + Double(elapsed.attoseconds) / 1e18
        guard seconds >= 0 else { return }
        let next = min(duration, position + seconds * speed)
        if let stop = reflectionIndices.sorted().first(where: {
            starts[$0] > position && starts[$0] <= next
        }) {
            position = starts[stop]
            isPlaying = false
            anchor = nil
            return
        }
        position = next
        anchor = now
        if isFinished {
            isPlaying = false
            anchor = nil
        }
    }
}
