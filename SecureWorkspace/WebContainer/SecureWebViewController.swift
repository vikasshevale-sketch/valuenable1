import UIKit
import WebKit

public class SecureWebViewController: UIViewController, WKNavigationDelegate {

    private var webView: WKWebView!
    private let targetURLString = "https://gmail.com"

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        loadInitialURL()
    }

    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        view.addSubview(webView)
    }

    private func loadInitialURL() {
        if let url = URL(string: targetURLString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    // MARK: - WKNavigationDelegate

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if DomainGuard.shared.isAllowed(url: url) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
}
