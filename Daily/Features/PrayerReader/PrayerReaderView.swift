import SwiftUI

struct PrayerReaderView: View {
    let session: PrayerSession
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage private var savedPosition: Double
    @AppStorage("readingSpeed") private var savedSpeed = 1.0
    @AppStorage("englishFirst") private var englishFirst = false
    @State private var playback: ReadingPlayback
    @State private var restored = false
    @ScaledMetric(relativeTo: .subheadline) private var controlHeight = 44

    init(session: PrayerSession) {
        self.session = session
        _savedPosition = AppStorage(wrappedValue: 0.0,
                                    session.readingPositionKey)
        _playback = State(initialValue: ReadingPlayback(
            durations: session.passages.map(\.readingDuration),
            reflectionIndices: Set(session.passages.indices.filter {
                session.passages[$0].pauseForReflection == true
            })))
    }

    private var currentID: String { session.passages[playback.index].id }
    private var currentProgress: String? {
        session.prayers.first { prayer in
            prayer.passages.contains { $0.id == currentID }
        }?.progress
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(session.prayers) { prayer in
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(englishFirst ? prayer.englishTitle :
                                     prayer.title).font(AppFont.heading)
                                Text(englishFirst ? prayer.title :
                                     prayer.englishTitle).font(AppFont.secondary)
                            }
                            .accessibilityAddTraits(.isHeader)
                            ForEach(prayer.passages) { passage in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(englishFirst ? passage.english :
                                         passage.latin).font(AppFont.primary)
                                    Text(englishFirst ? passage.latin :
                                         passage.english).font(AppFont.body)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .overlay(alignment: .leading) {
                                    if passage.id == currentID {
                                        Rectangle().frame(width: 2)
                                            .foregroundStyle(AppTheme.gold)
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
                if playback.isPlaying || playback.isWaitingForReflection {
                    scroll(proxy)
                }
            }
            .onAppear {
                guard !restored else { return }
                playback.seek(to: savedPosition)
                playback.setSpeed(savedSpeed)
                restored = true
                proxy.scrollTo(currentID, anchor: .top)
            }
        }
        .font(AppFont.body)
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
        .foregroundStyle(AppTheme.gold)
        .padding(.horizontal, 24)
        .background(.black)
    }

    private func controls(toggle: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            if playback.isWaitingForReflection {
                Text("take your time · continue when ready").font(AppFont.caption)
            }
            if let currentProgress {
                Text(currentProgress).font(AppFont.caption)
            }
            Text("silent reading · \(playback.index + 1)/\(session.passages.count)")
                .font(AppFont.caption)
            HStack(spacing: 8) {
                Button(playback.isPlaying ? "pause" :
                       playback.isWaitingForReflection ? "continue" :
                       playback.isFinished ? "restart" :
                       playback.position == 0 ? "start" : "resume",
                       action: toggle)
                    .buttonStyle(ReaderControlStyle(height: controlHeight))
                    .frame(minWidth: 0, maxWidth: .infinity)
                HStack(spacing: 4) {
                    Text("LA").accessibilityHidden(true)
                    Toggle("Primary prayer language", isOn: $englishFirst)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .tint(AppTheme.gold)
                        .accessibilityLabel("Primary prayer language")
                        .accessibilityValue(englishFirst ? "English first" :
                                           "Latin first")
                        .accessibilityHint("Changes which language appears first")
                    Text("EN").accessibilityHidden(true)
                }
                .font(AppFont.caption)
                .foregroundStyle(AppTheme.gold)
                .fixedSize()
                .frame(minHeight: 44)
                Menu {
                    ForEach(ReadingPlayback.speeds, id: \.self) { speed in
                        Button("\(speed.formatted())×") {
                            playback.setSpeed(speed)
                            savedSpeed = speed
                        }
                    }
                } label: {
                    Text("\(playback.speed.formatted())×")
                }
                .buttonStyle(ReaderControlStyle(height: controlHeight))
                .frame(minWidth: 0, maxWidth: .infinity)
                .accessibilityLabel("Reading speed")
                .accessibilityValue("\(playback.speed.formatted()) times")
            }
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

private struct ReaderControlStyle: ButtonStyle {
    let height: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, minHeight: height)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppTheme.gold, lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}
