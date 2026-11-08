import SwiftUI

struct MorningPrayerButton: View {
    @State private var isPresented = false

    var body: some View {
        Button("morning") { isPresented = true }
            .buttonStyle(.plain)
            .frame(minHeight: 44, alignment: .leading)
            .fullScreenCover(isPresented: $isPresented) {
                MorningPrayerScreen()
            }
    }
}

private struct MorningPrayerScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var session: PrayerSession?
    @State private var failed = false

    var body: some View {
        Group {
            if let session {
                PrayerReaderView(session: session)
            } else if failed {
                VStack(spacing: 24) {
                    Text("Morning prayers could not be opened.")
                    Button("back") { dismiss() }
                        .frame(minHeight: 44)
                }
                .padding()
            } else {
                ProgressView().tint(.white)
            }
        }
        .font(.system(.body, design: .monospaced))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .preferredColorScheme(.dark)
        .task {
            guard session == nil, !failed else { return }
            do { session = try PrayerSession.morning() }
            catch { failed = true }
        }
    }
}
