import SwiftUI

struct PrayerReaderView: View {
    let session: PrayerSession
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("morning.readingPosition") private var savedPosition = 0.0
    @AppStorage("readingSpeed") private var savedSpeed = 1.0
    @AppStorage("englishFirst") private var englishFirst = false
    @State private var playback: ReadingPlayback
    @State private var restored = false

    init(session: PrayerSession) {
        self.session = session
        _playback = State(initialValue: ReadingPlayback(
            durations: session.passages.map(\.readingDuration)))
    }

    private var currentID: String { session.passages[playback.index].id }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(session.prayers) { prayer in
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(englishFirst ? prayer.englishTitle :
                                     prayer.title).font(.title2.bold())
                                Text(englishFirst ? prayer.title :
                                     prayer.englishTitle).font(.subheadline)
                            }
                            .accessibilityAddTraits(.isHeader)
                            ForEach(prayer.passages) { passage in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(englishFirst ? passage.english :
                                         passage.latin).font(.title3)
                                    Text(englishFirst ? passage.latin :
                                         passage.english).font(.body)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .overlay(alignment: .leading) {
                                    if passage.id == currentID {
                                        Rectangle().frame(width: 2)
                                            .accessibilityHidden(true)
                                    }
                                }
                                .accessibilityElement(children: .combine)
                                .id(passage.id)
                                .onTapGesture {
                                    guard let index = session.passages
                                        .firstIndex(where: { $0.id == passage.id })
                                    else { return }
                                    playback.pause()
                                    playback.seek(to: playback.starts[index])
                                }
                                .accessibilityAction(named: "Read from here") {
                                    guard let index = session.passages
                                        .firstIndex(where: { $0.id == passage.id })
                                    else { return }
                                    playback.pause()
                                    playback.seek(to: playback.starts[index])
                                }
                            }
                        }
                    }
                    if playback.isFinished {
                        Text("amen. session complete.")
                    }
                }
                .padding(24)
            }
            .simultaneousGesture(DragGesture().onChanged { _ in
                playback.pause()
            })
            .safeAreaInset(edge: .top, spacing: 0) { header }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                controls {
                    if playback.isPlaying { playback.pause() }
                    else {
                        playback.play()
                        scroll(proxy)
                    }
                }
            }
            .onChange(of: playback.index) { _, _ in
                savedPosition = playback.position
                if playback.isPlaying { scroll(proxy) }
            }
            .onAppear {
                guard !restored else { return }
                playback.seek(to: savedPosition)
                playback.setSpeed(savedSpeed)
                restored = true
                proxy.scrollTo(currentID, anchor: .top)
            }
        }
        .fontDesign(.monospaced)
        .foregroundStyle(.white)
        .background(.black)
        .task(id: playback.isPlaying) {
            while playback.isPlaying && !Task.isCancelled {
                do { try await Task.sleep(for: .milliseconds(100)) }
                catch { return }
                playback.tick()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { pauseAndSave() }
        }
        .onChange(of: playback.isPlaying) { _, playing in
            if !playing { savedPosition = playback.position }
        }
        .onDisappear { pauseAndSave() }
    }

    private var header: some View {
        HStack {
            Button("back") {
                pauseAndSave()
                dismiss()
            }
            .frame(minHeight: 44)
            Spacer()
            Text(session.title).accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal, 24)
        .background(.black)
    }

    private func controls(toggle: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Text("silent reading · \(playback.index + 1)/\(session.passages.count)")
                .font(.caption)
            HStack {
                Button(playback.isPlaying ? "pause" :
                       playback.isFinished ? "restart" :
                       playback.position == 0 ? "start" : "resume",
                       action: toggle)
                    .frame(minWidth: 88, minHeight: 44)
                    .overlay(Rectangle().stroke(.white))
                Spacer()
                Menu {
                    ForEach(ReadingPlayback.speeds, id: \.self) { speed in
                        Button("\(speed.formatted())×") {
                            playback.setSpeed(speed)
                            savedSpeed = speed
                        }
                    }
                } label: {
                    Text("\(playback.speed.formatted())×")
                        .frame(minWidth: 64, minHeight: 44)
                        .overlay(Rectangle().stroke(.white))
                }
                .accessibilityLabel("Reading speed")
                .accessibilityValue("\(playback.speed.formatted()) times")
            }
            .buttonStyle(.plain)
            Button(englishFirst ? "english first" : "latin first") {
                englishFirst.toggle()
            }
            .buttonStyle(.plain)
            .font(.subheadline)
            .frame(maxWidth: .infinity, minHeight: 44)
            .overlay(Rectangle().stroke(.white))
            .accessibilityLabel("Primary prayer language")
            .accessibilityValue(englishFirst ? "English" : "Latin")
            .accessibilityHint(englishFirst ? "Switch to Latin first" :
                               "Switch to English first")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.black)
    }

    private func scroll(_ proxy: ScrollViewProxy) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            proxy.scrollTo(currentID, anchor: .top)
        }
    }

    private func pauseAndSave() {
        playback.pause()
        savedPosition = playback.position
    }
}
