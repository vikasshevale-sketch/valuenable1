import UIKit
import WebKit
import Combine

public final class SecureWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
    private var webView: WKWebView!
    private var cancellables = Set<AnyCancellable>()
    private let screenShareBlockerView = UIView()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private var progressObservation: NSKeyValueObservation?
    private var isShowingBlockedAlert = false

    private let startURL = URL(string: "https://mail.google.com/a/valuenable.in/")!

    /// Non-nil when this controller is a secondary window opened via
    /// window.open()/target=_blank (e.g. a Meet call launched from Chat)
    /// rather than the app's primary workspace screen.
    private let providedWebView: WKWebView?
    private var isPopupWindow: Bool { providedWebView != nil }
    private let closeButton = UIButton(type: .system)

    public init(popupWebView: WKWebView? = nil) {
        self.providedWebView = popupWebView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScreenCaptureProtection()
        if isPopupWindow {
            setupCloseButton()
        } else {
            loadWorkspace()
        }
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        if let providedWebView {
            // Reuse the WKWebView WebKit already created for this popup so
            // the JS window.opener relationship (and shared session/cookies)
            // stay intact.
            webView = providedWebView
        } else {
            let configuration = WKWebViewConfiguration()
            configuration.websiteDataStore = .default()
            configuration.allowsInlineMediaPlayback = true
            configuration.mediaTypesRequiringUserActionForPlayback = .all
            configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
            configuration.userContentController.addUserScript(WebSecurityScripts.dlpPreventionScript)
            webView = WKWebView(frame: .zero, configuration: configuration)
        }
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true

        let secureContainer = SecureContainerView(contentView: webView)
        view.addSubview(secureContainer)
        secureContainer.pinToSuperview()

        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])

        progressObservation = webView.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] webView, _ in
            DispatchQueue.main.async {
                self?.progressView.progress = Float(webView.estimatedProgress)
                self?.progressView.isHidden = webView.estimatedProgress >= 1.0
            }
        }

        setupScreenShareBlockerOverlay()
    }

    private func setupCloseButton() {
        closeButton.setTitle("✕ Close", for: .normal)
        closeButton.setTitleColor(.label, for: .normal)
        closeButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        closeButton.layer.cornerRadius = 8
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
        ])
    }

    @objc private func closeButtonTapped() {
        closeThisWindow()
    }

    private func closeThisWindow() {
        guard isPopupWindow else { return }
        if let nav = navigationController, nav.viewControllers.first !== self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    /// WKUIDelegate — called when the page itself calls window.close()
    /// (e.g. a Meet call window closing itself when the call ends).
    public func webViewDidClose(_ webView: WKWebView) {
        closeThisWindow()
    }

    private func setupScreenShareBlockerOverlay() {
        screenShareBlockerView.backgroundColor = .black
        screenShareBlockerView.translatesAutoresizingMaskIntoConstraints = false

        let warningLabel = UILabel()
        warningLabel.text = "🔒 Screen sharing or recording is blocked by Valuenable Security Policy."
        warningLabel.textColor = .white
        warningLabel.textAlignment = .center
        warningLabel.numberOfLines = 0
        warningLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        warningLabel.translatesAutoresizingMaskIntoConstraints = false

        screenShareBlockerView.addSubview(warningLabel)
        NSLayoutConstraint.activate([
            warningLabel.centerYAnchor.constraint(equalTo: screenShareBlockerView.centerYAnchor),
            warningLabel.leadingAnchor.constraint(equalTo: screenShareBlockerView.leadingAnchor, constant: 32),
            warningLabel.trailingAnchor.constraint(equalTo: screenShareBlockerView.trailingAnchor, constant: -32)
        ])

        view.addSubview(screenShareBlockerView)
        screenShareBlockerView.pinToSuperview()
        screenShareBlockerView.isHidden = true
    }

    private func setupScreenCaptureProtection() {
        ScreenCaptureMonitor.shared.$isScreenCaptured
            .receive(on: DispatchQueue.main)
            .sink { [weak self] captured in
                self?.screenShareBlockerView.isHidden = !captured
            }
            .store(in: &cancellables)
    }

    private func loadWorkspace() {
        guard DomainGuard.isURLAllowed(startURL) else { return }
        // Do not add X-GoogApps-Allowed-Domains or any other custom Google
        // authentication header. Google owns the redirect/cookie flow.
        webView.load(URLRequest(url: startURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30))
    }

    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        guard DomainGuard.isURLAllowed(url) else {
            decisionHandler(.cancel)
            if !DomainGuard.isBenignSentinelURL(url) {
                showDomainBlockedAlert(host: url.host)
            }
            return
        }

        if navigationAction.shouldPerformDownload {
            decisionHandler(.download)
            return
        }

        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(navigationResponse.canShowMIMEType ? .allow : .download)
    }

    public func webView(_ webView: WKWebView,
                        navigationAction: WKNavigationAction,
                        didBecome download: WKDownload) {
        download.delegate = self
    }

    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url, DomainGuard.isURLAllowed(url) else {
            if let url = navigationAction.request.url, !DomainGuard.isBenignSentinelURL(url) {
                showDomainBlockedAlert(host: url.host)
            }
            return nil
        }

        // Real second window (e.g. a Google Meet call started from a Chat
        // Space) — open it as a genuine separate WKWebView so JS window.open
        // / window.opener semantics work, rather than hijacking the current
        // page. It's pushed as another screen of THIS same secure app, so
        // every protection (domain lock, DLP script, screenshot/recording
        // blackout) still applies — it never leaves the secure container.
        configuration.userContentController.addUserScript(WebSecurityScripts.dlpPreventionScript)
        let popupWebView = WKWebView(frame: .zero, configuration: configuration)
        let popupController = SecureWebViewController(popupWebView: popupWebView)

        if let nav = navigationController {
            nav.pushViewController(popupController, animated: true)
        } else {
            popupController.modalPresentationStyle = .fullScreen
            present(popupController, animated: true)
        }

        return popupWebView
    }

    public func download(_ download: WKDownload,
                         decideDestinationUsing response: URLResponse,
                         suggestedFilename: String,
                         completionHandler: @escaping (URL?) -> Void) {
        let initialName = suggestedFilename.isEmpty ? "download" : suggestedFilename
        let safeName = initialName
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + "_" + safeName)
        completionHandler(destination)
    }

    public func downloadDidFinish(_ download: WKDownload) {}

    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        #if DEBUG
        print("[Download] Failed: \(error.localizedDescription)")
        #endif
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        logNavigationError("navigation", error)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        logNavigationError("provisional navigation", error)
    }

    private func logNavigationError(_ stage: String, _ error: Error) {
        #if DEBUG
        let nsError = error as NSError
        print("[WebView] \(stage) failed: domain=\(nsError.domain) code=\(nsError.code) message=\(nsError.localizedDescription)")
        #endif
    }

    private func showDomainBlockedAlert(host: String?) {
        guard !isShowingBlockedAlert else { return }
        isShowingBlockedAlert = true

        let displayHost = host?.isEmpty == false ? host! : "an unauthorized host"
        let alert = UIAlertController(
            title: "Access Restricted",
            message: "Navigation to \(displayHost) is blocked because this origin is not part of the Valuenable Workspace allow-list.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.isShowingBlockedAlert = false
        })
        present(alert, animated: true)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isShowingBlockedAlert = false
    }

    deinit {
        progressObservation?.invalidate()
    }
}
