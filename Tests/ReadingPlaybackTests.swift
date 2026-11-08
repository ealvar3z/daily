import XCTest
@testable import daily

final class ReadingPlaybackTests: XCTestCase {
    @MainActor
    func testSpeedChangeSettlesElapsedTimeAtPreviousRate() {
        let reader = ReadingPlayback(durations: [10, 10, 10])
        let start = ContinuousClock().now
        reader.play(now: start)
        reader.setSpeed(1.5, now: start.advanced(by: .seconds(4)))
        reader.tick(now: start.advanced(by: .seconds(8)))
        XCTAssertEqual(reader.position, 10, accuracy: 0.001)
        XCTAssertEqual(reader.index, 1)
    }

    @MainActor
    func testPauseExcludesTimeUntilResume() {
        let reader = ReadingPlayback(durations: [10, 10])
        let start = ContinuousClock().now
        reader.play(now: start)
        reader.pause(now: start.advanced(by: .seconds(3)))
        reader.tick(now: start.advanced(by: .seconds(50)))
        XCTAssertEqual(reader.position, 3, accuracy: 0.001)
        reader.play(now: start.advanced(by: .seconds(60)))
        reader.tick(now: start.advanced(by: .seconds(62)))
        XCTAssertEqual(reader.position, 5, accuracy: 0.001)
    }

    @MainActor
    func testCompletionClampsAndRestartReturnsToBeginning() {
        let reader = ReadingPlayback(durations: [5, 7])
        let start = ContinuousClock().now
        reader.play(now: start)
        reader.tick(now: start.advanced(by: .seconds(100)))
        XCTAssertEqual(reader.position, 12)
        XCTAssertEqual(reader.index, 1)
        XCTAssertTrue(reader.isFinished)
        XCTAssertFalse(reader.isPlaying)
        reader.play(now: start.advanced(by: .seconds(101)))
        XCTAssertEqual(reader.position, 0)
        XCTAssertEqual(reader.index, 0)
    }

    @MainActor
    func testSeekingResetsClockAnchorAndRejectsInvalidValues() {
        let reader = ReadingPlayback(durations: [10, 10, 10])
        let start = ContinuousClock().now
        reader.play(now: start)
        reader.seek(to: 20, now: start.advanced(by: .seconds(5)))
        reader.tick(now: start.advanced(by: .seconds(6)))
        XCTAssertEqual(reader.position, 21, accuracy: 0.001)
        reader.seek(to: .nan)
        XCTAssertEqual(reader.position, 21, accuracy: 0.001)
        reader.seek(to: -100)
        XCTAssertEqual(reader.position, 0)
        reader.seek(to: 100)
        XCTAssertEqual(reader.position, 30)
        XCTAssertFalse(reader.isPlaying)
    }

    @MainActor
    func testRestoringPositionDoesNotAutomaticallyStart() {
        let reader = ReadingPlayback(durations: [10, 10])
        reader.seek(to: 12)
        reader.setSpeed(1.25)
        XCTAssertEqual(reader.position, 12)
        XCTAssertEqual(reader.index, 1)
        XCTAssertFalse(reader.isPlaying)
    }

    func testMorningContentHasCompleteOrderAndDistinctOccurrences() throws {
        let session = try PrayerSession.morning()
        XCTAssertEqual(session.prayers.map(\.id), [
            "opening-cross", "faith", "hope", "charity", "our-father",
            "hail-mary", "glory-be", "guardian-angel", "closing-cross"
        ])
        XCTAssertEqual(session.passages.first?.latin,
                       session.passages.last?.latin)
        XCTAssertNotEqual(session.passages.first?.id,
                          session.passages.last?.id)
        XCTAssertEqual(Set(session.passages.map(\.id)).count,
                       session.passages.count)
        XCTAssertTrue(session.passages.allSatisfy { $0.readingDuration >= 5 })
    }
}
