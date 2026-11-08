import Foundation

struct PrayerSession: Decodable {
    struct Prayer: Decodable, Identifiable {
        let id: String
        let title: String
        let englishTitle: String
        let passages: [Passage]
        let progress: String?
    }

    struct Passage: Decodable, Identifiable {
        let id: String
        let latin: String
        let english: String
        let pauseForReflection: Bool?

        init(id: String, latin: String, english: String,
             pauseForReflection: Bool? = nil) {
            self.id = id
            self.latin = latin
            self.english = english
            self.pauseForReflection = pauseForReflection
        }

        var readingDuration: Double {
            let words = max(latin.split(whereSeparator: \.isWhitespace).count,
                            english.split(whereSeparator: \.isWhitespace).count)
            return max(5, Double(words) * 0.6 + 2)
        }
    }

    let id: String
    let title: String
    let provenance: [String: String]
    let prayers: [Prayer]

    var passages: [Passage] { prayers.flatMap(\.passages) }
    var readingPositionKey: String { "\(id).readingPosition" }

    static func morning(bundle: Bundle = .main) throws -> PrayerSession {
        try load("morning", bundle: bundle)
    }

    static func evening(bundle: Bundle = .main) throws -> PrayerSession {
        try load("evening", bundle: bundle)
    }

    private static func load(_ name: String, bundle: Bundle) throws -> Self {
        guard let url = bundle.url(forResource: name,
                                   withExtension: "json") else {
            throw ContentError.missing
        }
        let session = try JSONDecoder().decode(Self.self,
                                              from: Data(contentsOf: url))
        let passages = session.passages
        guard !session.prayers.isEmpty, !passages.isEmpty,
              Set(session.prayers.map(\.id)).count == session.prayers.count,
              Set(passages.map(\.id)).count == passages.count,
              session.prayers.allSatisfy({ !$0.passages.isEmpty }),
              passages.allSatisfy({ !$0.latin.isEmpty && !$0.english.isEmpty })
        else { throw ContentError.invalid }
        return session
    }

    enum ContentError: Error { case missing, invalid }
}
