import SwiftUI

struct HomeView: View {
    @ScaledMetric(relativeTo: .title2) private var blankLine = 32

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heading("daily prayer")
                    .padding(.bottom, blankLine)
                VStack(alignment: .leading, spacing: 0) {
                    MorningPrayerButton()
                    SessionPrayerButton(kind: .rosary)
                    SessionPrayerButton(kind: .evening)
                }
                .padding(.bottom, blankLine)
                heading("daily reading")
                    .padding(.bottom, blankLine)
                DailyReadingView()
                    .padding(.bottom, blankLine)
            }
            .font(AppFont.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(32)
        }
        .foregroundStyle(.white)
        .background(.black)
    }

    private func heading(_ title: String) -> some View {
        Text(title)
            .font(AppFont.largeTitle)
            .frame(maxWidth: .infinity, alignment: .center)
            .accessibilityAddTraits(.isHeader)
    }
}
