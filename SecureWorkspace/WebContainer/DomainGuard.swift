import WebKit

final class DomainGuard: NSObject, WKNavigationDelegate {
    private let allowedDomain = "valuenable.in"
    private let allowedAuthHosts = ["accounts.google.com", "ssl.gstatic.com", "gstatic.com"]
    
    weak var viewController: UIViewController?

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, let host = url.host?.lowercased() else {
            decisionHandler(.cancel)
            return
        }

        // Check 1: Org Domain
        if host == allowedDomain || host.hasSuffix("." + allowedDomain) {
            decisionHandler(.allow)
            return
        }

        // Check 2: Google SSO infrastructure
        if allowedAuthHosts.contains(where: { host == $0 || host.hasSuffix("." + $0) }) {
            // Block personal email query injections on accounts page
            if url.absoluteString.contains("Email=") && !url.absoluteString.contains("%40" + allowedDomain) && !url.absoluteString.contains("@" + allowedDomain) {
                notifyBlockedDomain(host)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
            return
        }

        // Reject external navigation
        notifyBlockedDomain(host)
        decisionHandler(.cancel)
    }

    private func notifyBlockedDomain(_ domain: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Domain Restricted",
                message: "Access to '\(domain)' is blocked. Only valuenable.in domains are permitted.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.viewController?.present(alert, animated: true)
        }
    }
}