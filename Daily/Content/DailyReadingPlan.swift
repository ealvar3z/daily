import Foundation

struct DailyReadingPlan: Sendable {
    struct Reading: Decodable, Equatable, Sendable {
        let day: Int
        let date: String
        let ot: String
        let nt: String
        let ps: String
        let prv: String
        let notes: [String]?
    }

    enum Selection: Equatable, Sendable {
        case reading(Reading)
        case catchUp
        case unavailable
    }

    enum LoadError: Error {
        case missingResource
        case invalidSchedule
    }

    private struct Document: Decodable {
        let days: [Reading]
    }

    private let readings: [String: Reading]

    init(data: Data) throws {
        let days = try JSONDecoder().decode(Document.self, from: data).days
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let start = calendar.date(from: DateComponents(year: 2001,
                                                       month: 1, day: 1))!
        guard days.count == 365 else { throw LoadError.invalidSchedule }
        var indexed: [String: Reading] = [:]
        for (index, reading) in days.enumerated() {
            let date = calendar.date(byAdding: .day, value: index,
                                     to: start)!
            let expected = Self.dateKey(date, timeZone: calendar.timeZone)
            guard reading.day == index + 1, reading.date == expected,
                  [reading.ot, reading.nt, reading.ps, reading.prv]
                    .allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty }) else {
                throw LoadError.invalidSchedule
            }
            indexed[reading.date] = reading
        }
        readings = indexed
    }

    static func load(bundle: Bundle = .main) throws -> DailyReadingPlan {
        guard let url = bundle.url(forResource: "daily-reading-plan",
                                   withExtension: "json") else {
            throw LoadError.missingResource
        }
        return try DailyReadingPlan(data: Data(contentsOf: url))
    }

    func selection(on date: Date, timeZone: TimeZone = .current) -> Selection {
        let key = Self.dateKey(date, timeZone: timeZone)
        if key == "02-29" { return .catchUp }
        guard let reading = readings[key] else { return .unavailable }
        return .reading(reading)
    }

    private static func dateKey(_ date: Date, timeZone: TimeZone) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(month < 10 ? "0" : "")\(month)-\(day < 10 ? "0" : "")\(day)"
    }
}
