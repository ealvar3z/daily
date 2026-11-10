import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("guide")
                    .font(AppFont.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityAddTraits(.isHeader)

                section("a daily rhythm", text: """
                Begin the morning with prayer. Make room for Scripture. \
                Return in the evening with thanksgiving.

                Use daily at your own pace. There is no need to hurry.
                """)

                section("daily prayer", text: """
                Choose Morning Session, Daily Rosary, or Evening Session.

                Morning and evening offer traditional Catholic prayers in \
                Latin and English. The rosary selects the mysteries for \
                the day.
                """)

                section("reading and controls", text: """
                Tap start to begin automatic scrolling. The gold marker \
                shows your current passage; the text remains white.

                Tap pause whenever you need more time, then resume when \
                you are ready. Scrolling by hand also pauses automatic \
                reading. Tap a passage to continue from that point.

                During a reflection pause, take as long as you need. \
                Tap continue when ready.

                The speed control adjusts the reading pace, including 2×. \
                Your selected speed is remembered.
                """)

                section("narration", text: """
                Narration is coming in an upcoming update, so you can \
                listen to the prayers while following the text. Until \
                then, use daily for silent reading and automatic scrolling.
                """)

                section("Latin and English", text: """
                Use the LA / EN switch to choose which language appears first.

                LA: Latin first, English beneath.
                EN: English first, Latin beneath.

                Your preference is remembered.

                Tap back to return home. Your place is saved for each \
                session. After finishing, tap restart to begin again.
                """)

                section("daily reading", text: """
                The home screen shows four readings for the day:

                OT: Old Testament, including the Apocrypha.
                NT: New Testament.
                Ps: Psalms.
                Prv: Proverbs.

                Read these passages in your own Bible. The plan follows \
                NRSV references and includes the full NRSV Apocrypha; \
                numbering and book availability may differ in other editions.

                Readings follow your local calendar date. February 29 is \
                a day to catch up or revisit a passage.
                """)

                section("daily mass", text: """
                Tap Find a Mass near you to open MassTimes and look for \
                a church and service time.
                """)

                VStack(alignment: .leading, spacing: 16) {
                    section("support this work", text: """
                    I am a writer and poet, and the maker of daily. \
                    Your support gives me time to write and to continue \
                    developing this app.

                    The best way to support my work is through an annual \
                    or monthly subscription to my Substack. An annual \
                    subscription offers steady support for the year ahead; \
                    a monthly subscription helps sustain the work along \
                    the way.

                    If daily has become part of your day, please consider \
                    helping me continue.
                    """)
                    Link(destination: URL(string:
                        "https://jjrgn.substack.com/71f88746")!) {
                        Text("Support this work")
                            .font(AppFont.heading)
                            .foregroundStyle(AppTheme.gold)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .font(AppFont.body)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func section(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFont.heading)
                .foregroundStyle(AppTheme.gold)
                .accessibilityAddTraits(.isHeader)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
