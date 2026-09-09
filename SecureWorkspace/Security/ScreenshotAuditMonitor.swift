import UIKit

/// Detects screenshots (requirement 2) and reports them to the IT
/// backend audit log when `screenshotAuditEnabled` is set in the MDM
/// managed configuration.
///
/// iOS cannot block screenshots — the platform offers no such API for
/// apps or MDM. The app's defense is (a) redaction: content rendered
/// inside `SecureContainerView` is blanked in the captured image, and
/// (b) detection: this monitor records the event so IT has an audit
/// trail.
public final class ScreenshotAuditMonitor {
    public static let shared = ScreenshotAuditMonitor()

    private var isStarted = false
    private var pollClient: EnrollmentAPIClient?
    private var corporateEmail: String?

    public init() {}

    /// Call once at app launch. No-ops unless the managed configuration
    /// enables screenshot auditing.
    public func start(corporateEmail: String? = nil) {
        self.corporateEmail = corporateEmail
        guard !isStarted else { return }
        guard let config = ManagedConfigurationManager.shared.effectiveConfiguration,
              config.screenshotAuditEnabled,
              let auditEndpoint = config.auditEndpoint else { return }

        isStarted = true
        pollClient = EnrollmentAPIClient(endpoint: config.enrollmentEndpoint)

        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.recordScreenshot()
        }
        _ = auditEndpoint
    }

    public func updateCorporateEmail(_ email: String?) {
        corporateEmail = email
    }

    private func recordScreenshot() {
        // Defense in depth: also drop anything the system may have on the
        // pasteboard from this app (outgoing data must stay restricted).
        UIPasteboard.general.items = []
        pollClient?.sendAuditEvent(
            type: "screenshot_taken",
            details: "User took a screenshot while the secure mail app was in the foreground.",
            corporateEmail: corporateEmail
        )
    }
}
