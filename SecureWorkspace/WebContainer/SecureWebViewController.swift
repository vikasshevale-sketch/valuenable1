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
        runSecurityVerification()
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
    }

    private func setupWebView() {
        let contentController = WKUserContentController()
        let script = WKUserScript(source: WebSecurityScripts.dlpScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(script)

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        domainGuard.viewController = self
        webView.navigationDelegate = domainGuard

        secureContainer.addContentView(webView)
    }

    private func runSecurityVerification() {
        #if !targetEnvironment(simulator)
        if JailbreakDetector.isJailbroken {
            showErrorAlert(title: "Security Warning", message: "Jailbroken environment detected. Workspace access is blocked.")
            return
        }
        #endif

        ScreenCaptureMonitor.shared.startMonitoring()
        loadWorkspace()
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

    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(alert, animated: true)
    }
}