import XCTest
@testable import daily

final class EveningTests: XCTestCase {
    func testEveningOrderAndIndependentBookmark() throws {
        let session = try PrayerSession.evening()
        XCTAssertEqual(session.prayers.map(\.id), [
            "opening-cross", "examination", "contrition", "our-father",
            "hail-mary", "glory-be", "salve", "eternal-rest", "closing-cross"
        ])
        XCTAssertEqual(session.readingPositionKey, "evening.readingPosition")
        XCTAssertNotEqual(session.readingPositionKey,
                          try PrayerSession.morning().readingPositionKey)
        XCTAssertEqual(session.passages.filter {
            $0.pauseForReflection == true
        }.map(\.id), ["examination-1"])
        XCTAssertEqual(Set(session.passages.map(\.id)).count,
                       session.passages.count)
        XCTAssertEqual(session.passages.first?.latin,
                       session.passages.last?.latin)
    }

    @MainActor
    func testLateTickAtDoubleSpeedCannotSkipReflection() {
        let reader = ReadingPlayback(durations: [5, 10, 20],
                                     reflectionIndices: [1])
        let start = ContinuousClock().now
        reader.setSpeed(2, now: start)
        reader.play(now: start)
        reader.tick(now: start.advanced(by: .seconds(60)))
        XCTAssertEqual(reader.position, 5)
        XCTAssertEqual(reader.index, 1)
        XCTAssertFalse(reader.isPlaying)
        XCTAssertTrue(reader.isWaitingForReflection)
        reader.tick(now: start.advanced(by: .seconds(600)))
        XCTAssertEqual(reader.position, 5)
    }

    @MainActor
    func testContinueStartsNextPrayerWithoutCountingReflectionTime() {
        let reader = ReadingPlayback(durations: [5, 10, 20],
                                     reflectionIndices: [1])
        let start = ContinuousClock().now
        reader.play(now: start)
        reader.tick(now: start.advanced(by: .seconds(5)))
        reader.play(now: start.advanced(by: .seconds(100)))
        XCTAssertEqual(reader.index, 2)
        XCTAssertEqual(reader.position, 15)
        XCTAssertTrue(reader.isPlaying)
        reader.tick(now: start.advanced(by: .seconds(102)))
        XCTAssertEqual(reader.position, 17, accuracy: 0.001)
    }

    @MainActor
    func testRestoredReflectionWaitsAndRestartStopsAgain() {
        let reader = ReadingPlayback(durations: [5, 10, 20],
                                     reflectionIndices: [1])
        let start = ContinuousClock().now
        reader.seek(to: 5, now: start)
        XCTAssertTrue(reader.isWaitingForReflection)
        reader.setSpeed(2, now: start)
        XCTAssertTrue(reader.isWaitingForReflection)
        reader.seek(to: reader.duration, now: start)
        reader.play(now: start)
        reader.tick(now: start.advanced(by: .seconds(3)))
        XCTAssertEqual(reader.position, 5)
        XCTAssertTrue(reader.isWaitingForReflection)
    }
}
