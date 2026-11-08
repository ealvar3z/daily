import XCTest
@testable import daily

final class RosaryTests: XCTestCase {
    private func calendar(_ zone: String = "UTC") -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone)!
        return calendar
    }

    private func date(_ value: String) -> Date {
        ISO8601DateFormatter().date(from: value)!
    }

    func testAllSevenWeekdays() {
        let calendar = calendar()
        let sunday = date("2026-11-08T12:00:00Z")
        let expected: [Rosary.Mysteries] = [
            .glorious, .joyful, .sorrowful, .glorious,
            .luminous, .sorrowful, .joyful
        ]
        for (offset, mysteries) in expected.enumerated() {
            let day = calendar.date(byAdding: .day, value: offset, to: sunday)!
            XCTAssertEqual(Rosary.Mysteries.today(on: day, calendar: calendar),
                           mysteries)
        }
    }

    func testSelectionUsesLocalDateRatherThanUTC() {
        let instant = date("2026-11-09T02:00:00Z")
        XCTAssertEqual(Rosary.Mysteries.today(on: instant,
                                             calendar: calendar()), .joyful)
        XCTAssertEqual(Rosary.Mysteries.today(on: instant,
                       calendar: calendar("America/New_York")), .glorious)
    }

    func testEachSetContainsCompleteOrderedRosary() throws {
        for day in [8, 9, 10, 12] {
            let session = try Rosary.session(
                on: date("2026-11-\(day < 10 ? "0" : "")\(day)T12:00:00Z"),
                calendar: calendar())
            let ids = session.prayers.map(\.id)
            XCTAssertEqual(ids.count, 81)
            XCTAssertEqual(Array(ids.prefix(7)), [
                "opening-cross", "creed", "opening-our-father",
                "opening-hail-mary-1", "opening-hail-mary-2",
                "opening-hail-mary-3", "opening-glory-be"
            ])
            for decade in 1...5 {
                let prefix = "decade-\(decade)"
                let offset = 7 + (decade - 1) * 14
                let expected = ["\(prefix)-mystery", "\(prefix)-our-father"]
                    + (1...10).map { "\(prefix)-hail-mary-\($0)" }
                    + ["\(prefix)-glory-be", "\(prefix)-fatima"]
                XCTAssertEqual(Array(ids[offset..<(offset + 14)]), expected)
            }
            XCTAssertEqual(Array(ids.suffix(4)), [
                "closing-salve", "closing-versicle", "closing-collect",
                "closing-cross"
            ])
            XCTAssertEqual(ids.filter { $0.contains("hail-mary") }.count, 53)
            XCTAssertEqual(ids.filter { $0.contains("our-father") }.count, 6)
            XCTAssertEqual(Set(session.passages.map(\.id)).count,
                           session.passages.count)
            XCTAssertTrue(session.passages.allSatisfy {
                !$0.latin.isEmpty && !$0.english.isEmpty
            })
        }
    }

    func testProgressIsSeparateAndChangesAtLocalMidnight() throws {
        let local = calendar("America/New_York")
        let before = try Rosary.session(on: date("2026-11-09T04:59:59Z"),
                                       calendar: local)
        let earlier = try Rosary.session(on: date("2026-11-08T12:00:00Z"),
                                        calendar: local)
        let after = try Rosary.session(on: date("2026-11-09T05:00:00Z"),
                                      calendar: local)
        let morning = try PrayerSession.morning()
        XCTAssertEqual(morning.readingPositionKey, "morning.readingPosition")
        XCTAssertNotEqual(before.readingPositionKey, morning.readingPositionKey)
        XCTAssertEqual(before.readingPositionKey, earlier.readingPositionKey)
        XCTAssertNotEqual(before.readingPositionKey, after.readingPositionKey)
        XCTAssertEqual(before.title, "rosary · glorious")
        XCTAssertEqual(after.title, "rosary · joyful")
    }
}
