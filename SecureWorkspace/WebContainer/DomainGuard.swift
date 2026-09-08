import WebKit

final class DomainGuard: NSObject, WKNavigationDelegate {
    private let allowedDomain = "valuenable.in"
    private let googleAuthHosts = [
        "accounts.google.com",
        "ssl.gstatic.com",
        "gstatic.com",
        "google.com",
        "myaccount.google.com"
    ]
    
    weak var viewController: UIViewController?

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
              let host = url.host?.lowercased() else {
            decisionHandler(.allow)
            return
        }

        // 1. Allow valuenable.in internal routing
        if host == allowedDomain || host.hasSuffix("." + allowedDomain) {
            decisionHandler(.allow)
            return
        }

        // 2. Allow Google Authentication flow
        if googleAuthHosts.contains(where: { host == $0 || host.hasSuffix("." + $0) }) {
            // Block attempt if trying to input non-valuenable account directly
            let urlString = url.absoluteString.lowercased()
            if urlString.contains("email=") && !urlString.contains("valuenable.in") {
                notifyBlockedDomain(domain: "Unauthorized Email Account")
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
            return
        }

        // 3. Block external web links
        notifyBlockedDomain(domain: host)
        decisionHandler(.cancel)
    }

    private func notifyBlockedDomain(domain: String) {
        DispatchQueue.main.async { [weak self] in
            guard let vc = self?.viewController else { return }
            let alert = UIAlertController(
                title: "Domain Restricted",
                message: "Access to '\(domain)' is blocked. Only @valuenable.in accounts and domains are allowed.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            vc.present(alert, animated: true)
        }
    }
}