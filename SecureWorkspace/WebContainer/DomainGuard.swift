import Foundation

/// Centralized allow-list for the Valuenable Workspace web container.
///
/// Google Workspace is a multi-origin web application: the initial Gmail URL
/// may legitimately redirect to Google authentication and load resources from
/// Google-owned origins. We therefore allow the Valuenable company domain and
/// only the Google origins required by the Workspace web flow.
public enum DomainGuard {
    public static let allowedCompanyDomain = "valuenable.in"

    private static let allowedHosts: Set<String> = [
        // Google Workspace / Gmail
        "mail.google.com",
        "accounts.google.com",
        "accounts.google.co.in",
        "apis.google.com",
        "ogs.google.com",
        "clients6.google.com",
        "clients1.google.com",
        "www.google.com",
        "www.google.co.in",
        "google.com",

        // Google APIs / static content used by Workspace
        "googleapis.com",
        "gstatic.com",
        "www.gstatic.com",
        "ssl.gstatic.com",
        "fonts.gstatic.com",
        "fonts.googleapis.com",
        "oauth2.googleapis.com",
        "lh3.googleusercontent.com",
        "lh4.googleusercontent.com",
        "lh5.googleusercontent.com",
        "lh6.googleusercontent.com",
        "googleusercontent.com",

        // Workspace products that may be opened from Gmail
        "drive.google.com",
        "docs.google.com",
        "sheets.google.com",
        "slides.google.com",
        "calendar.google.com",
        "contacts.google.com",
        "meet.google.com"
    ]

    private static let allowedSuffixes: [String] = [
        ".googleapis.com",
        ".gstatic.com",
        ".googleusercontent.com"
    ]

    public static func isHostAllowed(_ host: String?) -> Bool {
        guard var normalized = host?.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: ".")),
              !normalized.isEmpty else { return false }

        // URL.host can be an IPv6/IDNA value; this guard keeps the comparison
        // strictly hostname based and never permits arbitrary schemes.
        normalized = normalized.trimmingCharacters(in: .whitespacesAndNewlines)

        if normalized == allowedCompanyDomain || normalized.hasSuffix("." + allowedCompanyDomain) {
            return true
        }

        if allowedHosts.contains(normalized) {
            return true
        }

        return allowedSuffixes.contains { normalized.hasSuffix($0) }
    }

    public static func isURLAllowed(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https" else { return false }
        return isHostAllowed(url.host)
    }

    /// Kept for source compatibility. No authentication headers are injected.
    public static func applyDomainRestrictionHeaders(to request: inout URLRequest) {}
}
