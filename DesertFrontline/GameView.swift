import SpriteKit
import SwiftUI
import UIKit

struct GameView: View {
    @StateObject private var holder = SceneHolder()

    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: holder.scene, preferredFramesPerSecond: 60)
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
            guard let window else { return }
            onChange?(window.safeAreaInsets)
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
        guard size.width > 1, size.height > 1, scene.size != size else { return }
        scene.size = size
    }
}
