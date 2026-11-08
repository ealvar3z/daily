import XCTest
@testable import daily

final class DailyReadingPlanTests: XCTestCase {
    private let utc = TimeZone(secondsFromGMT: 0)!

    private func instant(_ text: String) -> Date {
        ISO8601DateFormatter().date(from: text)!
    }

    private func reading(_ plan: DailyReadingPlan, at date: Date,
                         zone: TimeZone) throws -> DailyReadingPlan.Reading {
        guard case .reading(let value) = plan.selection(on: date,
                                                        timeZone: zone) else {
            XCTFail("Expected a reading")
            throw DailyReadingPlan.LoadError.invalidSchedule
        }
        return value
    }

    func testEveryDayHasFourReadingsAndYearRepeats() throws {
        let plan = try DailyReadingPlan.load()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        let start = instant("2025-01-01T12:00:00Z")
        var keys = Set<String>()
        for index in 0..<365 {
            let date = calendar.date(byAdding: .day, value: index, to: start)!
            let value = try reading(plan, at: date, zone: utc)
            XCTAssertEqual(value.day, index + 1)
            XCTAssertTrue(keys.insert(value.date).inserted)
            XCTAssertTrue([value.ot, value.nt, value.ps, value.prv]
                .allSatisfy { !$0.isEmpty })
        }
        let first = try reading(plan, at: start, zone: utc)
        XCTAssertEqual(first.ot, "Gn 1:1–3:24")
        XCTAssertEqual(first, try reading(plan,
            at: instant("2027-01-01T12:00:00Z"), zone: utc))
        let last = try reading(plan,
            at: instant("2025-12-31T12:00:00Z"), zone: utc)
        XCTAssertEqual(last.ot, "4 Macc 16:1–18:24")
        XCTAssertEqual(last.ps, "151:1–7")
    }

    func testLeapDayDoesNotShiftMarch() throws {
        let plan = try DailyReadingPlan.load()
        XCTAssertEqual(plan.selection(on: instant("2028-02-29T12:00:00Z"),
                                      timeZone: utc), .catchUp)
        XCTAssertEqual(try reading(plan,
            at: instant("2028-02-28T12:00:00Z"), zone: utc).day, 59)
        let march = try reading(plan,
            at: instant("2028-03-01T12:00:00Z"), zone: utc)
        XCTAssertEqual(march.day, 60)
        XCTAssertEqual(march, try reading(plan,
            at: instant("2027-03-01T12:00:00Z"), zone: utc))
    }

    func testLocalMidnightAndTimeZoneChange() throws {
        let plan = try DailyReadingPlan.load()
        let west = TimeZone(identifier: "America/Los_Angeles")!
        let east = TimeZone(identifier: "Asia/Tokyo")!
        let sameInstant = instant("2027-01-01T01:00:00Z")
        XCTAssertEqual(try reading(plan, at: sameInstant, zone: west).date,
                       "12-31")
        XCTAssertEqual(try reading(plan, at: sameInstant, zone: east).date,
                       "01-01")
        XCTAssertEqual(try reading(plan,
            at: instant("2027-01-01T07:59:59Z"), zone: west).date, "12-31")
        XCTAssertEqual(try reading(plan,
            at: instant("2027-01-01T08:00:00Z"), zone: west).date, "01-01")
    }

    func testDaylightSavingTransitionsKeepSameReading() throws {
        let plan = try DailyReadingPlan.load()
        let zone = TimeZone(identifier: "America/New_York")!
        for pair in [
            ("2026-03-08T06:59:59Z", "2026-03-08T07:00:00Z"),
            ("2026-11-01T05:59:59Z", "2026-11-01T06:00:00Z")
        ] {
            XCTAssertEqual(try reading(plan, at: instant(pair.0), zone: zone),
                           try reading(plan, at: instant(pair.1), zone: zone))
        }
    }

    func testSpecialReadingsRetainInstructions() throws {
        let plan = try DailyReadingPlan.load()
        let sirach = try reading(plan,
            at: instant("2026-10-17T12:00:00Z"), zone: utc)
        XCTAssertTrue(sirach.ot.contains("Prologue"))
        XCTAssertFalse(sirach.notes?.isEmpty ?? true)
        let esther = try reading(plan,
            at: instant("2026-10-09T12:00:00Z"), zone: utc)
        XCTAssertEqual(esther.ot, "Gk Est 15:1–16; 5:3–7:10")
    }

    func testRejectsMissingDuplicateAndEmptyEntries() throws {
        let url = try XCTUnwrap(Bundle.main.url(
            forResource: "daily-reading-plan", withExtension: "json"))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(
            with: Data(contentsOf: url)) as? [String: Any])
        let days = try XCTUnwrap(object["days"] as? [[String: Any]])
        var duplicate = days
        duplicate[1] = days[0]
        var blank = days
        blank[0]["ot"] = "  "
        for broken in [Array(days.dropLast()), duplicate, blank] {
            let data = try JSONSerialization.data(withJSONObject: ["days": broken])
            XCTAssertThrowsError(try DailyReadingPlan(data: data))
        }
    }
}
