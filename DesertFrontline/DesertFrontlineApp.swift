import SwiftUI

@main
struct DesertFrontlineApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
                .statusBarHidden(true)
        }
    }
}
