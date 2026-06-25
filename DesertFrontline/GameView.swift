import SpriteKit
import SwiftUI

struct GameView: View {
    @StateObject private var holder = SceneHolder()

    var body: some View {
        SpriteView(scene: holder.scene, preferredFramesPerSecond: 60)
            .ignoresSafeArea()
    }
}

@MainActor
final class SceneHolder: ObservableObject {
    let scene: GameScene

    init() {
        let sceneSize = CGSize(width: 1366, height: 1024)
        let scene = GameScene(size: sceneSize)
        scene.scaleMode = .aspectFill
        self.scene = scene
    }
}
