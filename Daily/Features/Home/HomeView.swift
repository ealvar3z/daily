import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("daily")
                    .font(.system(.largeTitle, design: .monospaced).bold())
                    .accessibilityAddTraits(.isHeader)
                Text("morning")
                Text("rosary")
                Text("evening")
            }
            .font(.system(.title2, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(32)
        }
        .foregroundStyle(.white)
        .background(.black)
    }
}

