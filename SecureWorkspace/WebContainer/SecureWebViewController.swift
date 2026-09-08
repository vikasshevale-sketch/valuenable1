import UIKit
import WebKit

final class SecureWebViewController: UIViewController {
    private var webView: WKWebView!
    private let secureContainer = SecureContainerView()
    private let domainGuard = DomainGuard()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        enforceSecurityChecks()
        loadWorkspace()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(secureContainer)
        secureContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            secureContainer.topAnchor.constraint(equalTo: view.topAnchor),
            secureContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            secureContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            secureContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        title = "Secure Workspace"
    }

    private func setupWebView() {
        let contentController = WKUserContentController()
        let script = WKUserScript(source: WebSecurityScripts.dlpScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(script)

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.limitsNavigationsToAppBoundDomains = true

        webView = WKWebView(frame: .zero, configuration: config)
        domainGuard.viewController = self
        webView.navigationDelegate = domainGuard

        secureContainer.addContentView(webView)
    }

    private func enforceSecurityChecks() {
        if JailbreakDetector.isJailbroken {
            showFatalError("Untrusted Environment: Device is jailbroken.")
            return
        }

        ScreenCaptureMonitor.shared.startMonitoring()
        
        BiometricAuthManager.shared.authenticateUser { [weak self] success, _ in
            if !success {
                self?.showFatalError("Authentication required to access workspace.")
            }
        }
    }

    private func loadWorkspace() {
        var components = URLComponents(string: "https://accounts.google.com/AccountChooser")
        components?.queryItems = [
            URLQueryItem(name: "hd", value: "valuenable.in"),
            URLQueryItem(name: "continue", value: "https://mail.google.com/")
        ]
        
        if let url = components?.url {
            webView.load(URLRequest(url: url))
        }
    }

    private func showFatalError(_ message: String) {
        let alert = UIAlertController(title: "Access Denied", message: message, preferredStyle: .alert)
        present(alert, animated: true) {
            self.webView.isHidden = true
        }
    }
}