import SwiftUI

@main
struct DailyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .tint(.white)
            .preferredColorScheme(.dark)
        }
    }
}

