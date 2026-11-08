import SwiftUI

struct MorningPrayerButton: View {
    var body: some View { SessionPrayerButton(kind: .morning) }
}

enum PrayerSessionKind: String {
    case morning, rosary, evening
}

struct SessionPrayerButton: View {
    let kind: PrayerSessionKind
    @State private var isPresented = false

    var body: some View {
        Button { isPresented = true } label: {
            Text(kind.rawValue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
            .buttonStyle(.plain)
            .fullScreenCover(isPresented: $isPresented) {
                SessionPrayerScreen(kind: kind)
            }
    }
}

private struct SessionPrayerScreen: View {
    let kind: PrayerSessionKind
    @Environment(\.dismiss) private var dismiss
    @State private var session: PrayerSession?
    @State private var failed = false

    var body: some View {
        Group {
            if let session {
                PrayerReaderView(session: session)
            } else if failed {
                VStack(spacing: 24) {
                    Text("Prayers could not be opened.")
                    Button("back") { dismiss() }
                        .frame(minHeight: 44)
                }
                .padding()
            } else {
                ProgressView().tint(.white)
            }
        }
        .font(AppFont.body)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .preferredColorScheme(.dark)
        .task {
            guard session == nil, !failed else { return }
            do {
                switch kind {
                case .morning: session = try PrayerSession.morning()
                case .rosary: session = try Rosary.session()
                case .evening: session = try PrayerSession.evening()
                }
            }
            catch { failed = true }
        }
    }
}
