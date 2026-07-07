import SpriteKit
import SwiftUI

struct GameView: View {
    @StateObject private var holder = SceneHolder()

    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: holder.scene, preferredFramesPerSecond: 60)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .background(Color.black)
                .onAppear {
                    holder.resizeScene(to: proxy.size)
                }
                .onChange(of: proxy.size) { _, newSize in
                    holder.resizeScene(to: newSize)
                }
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}

@MainActor
final class SceneHolder: ObservableObject {
    let scene: GameScene

    init() {
        let sceneSize = CGSize(width: 1366, height: 1024)
        let scene = GameScene(size: sceneSize)
        scene.scaleMode = .resizeFill
        self.scene = scene
    }

    func resizeScene(to size: CGSize) {
        guard size.width > 1, size.height > 1, scene.size != size else { return }
        scene.size = size
    }
}
