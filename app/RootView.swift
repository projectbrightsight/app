import SwiftUI

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        if showSplash {
            SplashView(isActive: $showSplash)
        } else {
            MainMenuView() // 🔁 Replace ContentView() with MainMenuView()
        }
    }
}
