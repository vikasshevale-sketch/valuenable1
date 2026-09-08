import UIKit

final class ScreenCaptureMonitor {
    static let shared = ScreenCaptureMonitor()
    private var warningWindow: UIWindow?

    private init() {}

    func startMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCapturedChanged),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }

    @objc private func screenCapturedChanged() {
        if UIScreen.main.isCaptured {
            showRecordingWarning()
        } else {
            hideRecordingWarning()
        }
    }

    @objc private func userDidTakeScreenshot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        
        let alert = UIAlertController(
            title: "Security Violation",
            message: "Screenshots are restricted by enterprise policy. Screen content is obscured.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Acknowledge", style: .default))
        rootVC.present(alert, animated: true)
    }

    private func showRecordingWarning() {
        guard warningWindow == nil,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.windowLevel = .alert + 1
        
        let vc = UIViewController()
        vc.view.backgroundColor = .black
        
        let label = UILabel()
        label.text = "Screen Recording Detected\nContent Hidden"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .bold)
        
        vc.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.warningWindow = window
    }

    private func hideRecordingWarning() {
        warningWindow?.isHidden = true
        warningWindow = nil
    }
}