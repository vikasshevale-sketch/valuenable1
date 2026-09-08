import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var blurEffectView: UIVisualEffectView?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let webVC = SecureWebViewController()
        let navController = UINavigationController(rootViewController: webVC)
        
        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        showBlurOverlay()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        hideBlurOverlay()
    }

    private func showBlurOverlay() {
        guard blurEffectView == nil, let window = window else { return }
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = window.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(blurView)
        self.blurEffectView = blurView
    }

    private func hideBlurOverlay() {
        blurEffectView?.removeFromSuperview()
        blurEffectView = nil
    }
}