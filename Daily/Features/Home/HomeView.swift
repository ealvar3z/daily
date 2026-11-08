import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("daily prayer")
                    .font(AppFont.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityAddTraits(.isHeader)
                MorningPrayerButton()
                SessionPrayerButton(kind: .rosary)
                SessionPrayerButton(kind: .evening)
            }
            .font(AppFont.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(32)
        }
        .foregroundStyle(.white)
        .background(.black)
    }
}

