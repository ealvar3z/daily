import Foundation

enum Rosary {
    enum Mysteries: String, CaseIterable {
        case joyful, sorrowful, glorious, luminous

        static func today(on date: Date, calendar: Calendar) -> Self {
            switch calendar.component(.weekday, from: date) {
            case 2, 7: .joyful
            case 3, 6: .sorrowful
            case 5: .luminous
            default: .glorious
            }
        }
    }

    private struct Catalog: Decodable {
        let provenance: [String: String]
        let prayers: [PrayerSession.Prayer]
        let mysteries: [String: [PrayerSession.Prayer]]
    }

    static func session(on date: Date = .now,
                        calendar: Calendar = .current,
                        bundle: Bundle = .main) throws -> PrayerSession {
        guard let url = bundle.url(forResource: "rosary",
                                   withExtension: "json") else {
            throw PrayerSession.ContentError.missing
        }
        let catalog = try JSONDecoder().decode(Catalog.self,
                                              from: Data(contentsOf: url))
        let kind = Mysteries.today(on: date, calendar: calendar)
        guard Set(catalog.prayers.map(\.id)).count == catalog.prayers.count,
              let mysteries = catalog.mysteries[kind.rawValue],
              mysteries.count == 5 else {
            throw PrayerSession.ContentError.invalid
        }
        let templates = Dictionary(uniqueKeysWithValues:
            catalog.prayers.map { ($0.id, $0) })
        var prayers: [PrayerSession.Prayer] = []

        func occurrence(_ template: PrayerSession.Prayer, id: String,
                        progress: String? = nil) -> PrayerSession.Prayer {
            PrayerSession.Prayer(
                id: id, title: template.title,
                englishTitle: template.englishTitle,
                passages: template.passages.enumerated().map { index, passage in
                    PrayerSession.Passage(id: "\(id)-\(index + 1)",
                                          latin: passage.latin,
                                          english: passage.english)
                }, progress: progress)
        }

        func append(_ templateID: String, _ occurrenceID: String,
                    progress: String? = nil) throws {
            guard let template = templates[templateID] else {
                throw PrayerSession.ContentError.invalid
            }
            prayers.append(occurrence(template, id: occurrenceID,
                                      progress: progress))
        }

        try append("cross", "opening-cross")
        try append("creed", "creed")
        try append("our-father", "opening-our-father")
        for bead in 1...3 {
            try append("hail-mary", "opening-hail-mary-\(bead)",
                       progress: "opening · bead \(bead)/3")
        }
        try append("glory-be", "opening-glory-be")
        for (index, mystery) in mysteries.enumerated() {
            let decade = index + 1
            let prefix = "decade-\(decade)"
            let progress = "\(kind.rawValue) · decade \(decade)/5"
            prayers.append(occurrence(mystery, id: "\(prefix)-mystery",
                                      progress: progress))
            try append("our-father", "\(prefix)-our-father", progress: progress)
            for bead in 1...10 {
                try append("hail-mary", "\(prefix)-hail-mary-\(bead)",
                           progress: "\(progress) · bead \(bead)/10")
            }
            try append("glory-be", "\(prefix)-glory-be", progress: progress)
            try append("fatima", "\(prefix)-fatima", progress: progress)
        }
        try append("salve", "closing-salve")
        try append("versicle", "closing-versicle")
        try append("collect", "closing-collect")
        try append("cross", "closing-cross")
        let day = calendar.dateComponents([.era, .year, .month, .day], from: date)
        let dayID = "\(day.era ?? 1)-\(day.year ?? 0)-\(day.month ?? 0)-\(day.day ?? 0)"
        let session = PrayerSession(
            id: "rosary-\(dayID)-\(kind.rawValue)",
            title: "rosary · \(kind.rawValue)",
            provenance: catalog.provenance, prayers: prayers)
        guard prayers.allSatisfy({ !$0.passages.isEmpty }),
              session.passages.allSatisfy({
                  !$0.latin.isEmpty && !$0.english.isEmpty
              }),
              Set(session.passages.map(\.id)).count == session.passages.count
        else { throw PrayerSession.ContentError.invalid }
        return session
    }
}
