import SpriteKit
import SwiftUI
import UIKit

struct GameView: View {
    @StateObject private var holder = SceneHolder()

    var body: some View {
        GeometryReader { proxy in
            // Keep the full layered tree; cloud captures must not lose HUD or units to host culling.
            SpriteView(scene: holder.scene, preferredFramesPerSecond: 60, options: [])
                .frame(width: proxy.size.width, height: proxy.size.height)
                .background(Color.black)
                .background(WindowSafeAreaObserver { insets in
                    holder.scene.updateWindowSafeAreaInsets(insets)
                })
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

private struct WindowSafeAreaObserver: UIViewRepresentable {
    var onChange: (UIEdgeInsets) -> Void

    func makeUIView(context: Context) -> SafeAreaView {
        let view = SafeAreaView()
        view.isUserInteractionEnabled = false
        view.onChange = onChange
        return view
    }

    func updateUIView(_ uiView: SafeAreaView, context: Context) {
        uiView.onChange = onChange
        uiView.reportInsets()
    }

    final class SafeAreaView: UIView {
        var onChange: ((UIEdgeInsets) -> Void)?
        private var reportScheduled = false
        private var lastReported: UIEdgeInsets?
        override func didMoveToWindow() {
            super.didMoveToWindow()
            reportInsets()
        }
        override func safeAreaInsetsDidChange() {
            super.safeAreaInsetsDidChange()
            reportInsets()
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            reportInsets()
        }
        func reportInsets() {
            guard window != nil, !reportScheduled else { return }
            reportScheduled = true
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.reportScheduled = false
                guard let insets = self.window?.safeAreaInsets, insets != self.lastReported else { return }
                self.lastReported = insets
                self.onChange?(insets)
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

    func resizeScene(to size: CGSize) {
        scene.requestViewSize(size)
    }
}
