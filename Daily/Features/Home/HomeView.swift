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
                heading("daily mass")
                    .padding(.bottom, blankLine)
                Link(destination: URL(string: "https://masstimes.org")!) {
                    HomeNavigationLabel(title: "Find a Mass near you")
                }
                .buttonStyle(.plain)
                .padding(.bottom, blankLine)
            }
            .font(AppFont.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Link(destination: URL(string:
                "https://jjrgn.substack.com/71f88746")!) {
                Text("Support this work")
                    .font(AppFont.captionBold)
                    .foregroundStyle(AppTheme.gold)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.black)
        }
        .foregroundStyle(.white)
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topTrailing) {
            NavigationLink {
                HelpView()
            } label: {
                Image(systemName: "book")
                    .symbolVariant(.none)
                    .symbolRenderingMode(.monochrome)
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("User Guide")
            .padding(.trailing, 16)
        }
    }

    private func heading(_ title: String) -> some View {
        Text(title)
            .font(AppFont.largeTitle)
            .foregroundStyle(AppTheme.gold)
            .frame(maxWidth: .infinity, alignment: .center)
            .accessibilityAddTraits(.isHeader)
    }
}

struct HomeNavigationLabel: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.body)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .contentShape(Rectangle())
    }
}
