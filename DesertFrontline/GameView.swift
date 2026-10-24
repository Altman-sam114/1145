import SpriteKit
import SwiftUI
import UIKit

struct GameView: View {
    @StateObject private var holder = SceneHolder()

    var body: some View {
        GameSurface(scene: holder.scene)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
    }
}

private struct GameSurface: UIViewRepresentable {
    let scene: GameScene

    func makeUIView(context: Context) -> GameRenderView {
        let view = GameRenderView(frame: .zero)
        view.backgroundColor = .black
        view.preferredFramesPerSecond = 60
        view.shouldCullNonVisibleNodes = false
        view.ignoresSiblingOrder = false
        view.isMultipleTouchEnabled = true
        view.setTargetScene(scene)
        return view
    }

    func updateUIView(_ uiView: GameRenderView, context: Context) {
        uiView.setTargetScene(scene)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: GameRenderView, context: Context) -> CGSize? {
        guard let width = proposal.width, let height = proposal.height,
              width.isFinite, height.isFinite else { return nil }
        return CGSize(width: width, height: height)
    }

    static func dismantleUIView(_ uiView: GameRenderView, coordinator: ()) {
        uiView.setTargetScene(nil)
        uiView.presentScene(nil)
    }
}

private final class GameRenderView: SKView {
    private weak var targetScene: GameScene?
    private var synchronizationScheduled = false
    private var lastSize: CGSize?
    private var lastInsets: UIEdgeInsets?

    func setTargetScene(_ scene: GameScene?) {
        if targetScene !== scene {
            targetScene = scene
            lastSize = nil
            lastInsets = nil
        }
        scheduleSynchronization()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        scheduleSynchronization()
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        scheduleSynchronization()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scheduleSynchronization()
    }

    private func scheduleSynchronization() {
        guard !synchronizationScheduled else { return }
        synchronizationScheduled = true
        // Present only after layout, using the actual rendering surface's geometry.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.synchronizationScheduled = false
            guard let game = self.targetScene, let window = self.window,
                  self.bounds.width > 1, self.bounds.height > 1 else { return }
            if self.lastSize != self.bounds.size {
                game.requestViewSize(self.bounds.size)
                self.lastSize = self.bounds.size
            }
            if self.lastInsets != window.safeAreaInsets {
                game.updateWindowSafeAreaInsets(window.safeAreaInsets)
                self.lastInsets = window.safeAreaInsets
            }
            if self.scene !== game {
                self.presentScene(game)
            }
        }
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
}
