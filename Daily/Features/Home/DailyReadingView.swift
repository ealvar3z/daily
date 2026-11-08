import SwiftUI
import UIKit

struct DailyReadingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ScaledMetric(relativeTo: .title2) private var labelWidth = 48
    @State private var plan: DailyReadingPlan?
    @State private var date = Date()
    @State private var loadFailed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let plan {
                switch plan.selection(on: date) {
                case .reading(let reading):
                    VStack(alignment: .leading, spacing: 0) {
                        row("OT", name: "Old Testament and Apocrypha",
                            reference: reading.ot)
                        row("NT", name: "New Testament", reference: reading.nt)
                        row("Ps", name: "Psalms", reference: reading.ps)
                        row("Prv", name: "Proverbs", reference: reading.prv)
                    }
                    if let notes = reading.notes {
                        ForEach(notes, id: \.self) { note in
                            Text(note)
                                .font(AppFont.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                case .catchUp:
                    Text("catch up and reflect\nnew readings resume tomorrow")
                        .font(AppFont.body)
                case .unavailable:
                    unavailable
                }
            } else if loadFailed {
                unavailable
            } else {
                Text("loading readings…")
                    .font(AppFont.body)
            }
        }
        .font(AppFont.title)
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            do {
                let loaded = try await Task.detached(priority: .userInitiated) {
                    try DailyReadingPlan.load()
                }.value
                guard !Task.isCancelled else { return }
                plan = loaded
                date = Date()
            } catch {
                loadFailed = true
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { date = Date() }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.significantTimeChangeNotification
        )) { _ in date = Date() }
        .onReceive(NotificationCenter.default.publisher(
            for: NSNotification.Name.NSSystemTimeZoneDidChange
        )) { _ in date = Date() }
    }

    private var unavailable: some View {
        Text("readings unavailable")
            .font(AppFont.body)
    }

    private func row(_ label: String, name: String,
                     reference: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("\(label):")
                .fixedSize()
                .frame(width: labelWidth, alignment: .leading)
            Text(reference)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name): \(reference)")
    }
}
