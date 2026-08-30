import Foundation

/// Allows only the Valuenable Workspace plus the Google hosts required by the
/// normal Google Workspace login/redirect flow. This class does not modify
/// HTTP headers or cookies.
public enum DomainGuard {
    public static let allowedCompanyDomain = "valuenable.in"

    private static let allowedHosts: Set<String> = [
        "accounts.google.com",
        "accounts.google.co.in",
        "oauth2.googleapis.com",
        "apis.google.com",
        "www.google.com",
        "www.google.co.in",
        "www.gstatic.com",
        "ssl.gstatic.com",
        "gstatic.com",
        "googleusercontent.com",
        "googleapis.com",
        "mail.google.com",
        "drive.google.com",
        "docs.google.com",
        "calendar.google.com"
    ]

    public static func isHostAllowed(_ host: String?) -> Bool {
        guard let normalized = host?.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: ".")),
              !normalized.isEmpty else { return false }

        if normalized == allowedCompanyDomain || normalized.hasSuffix("." + allowedCompanyDomain) {
            return true
        }

        return allowedHosts.contains { normalized == $0 || normalized.hasSuffix("." + $0) }
    }

    public static func isURLAllowed(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https" else { return false }
        return isHostAllowed(url.host)
    }

    /// Kept only for source compatibility. Do not add Google-specific headers.
    public static func applyDomainRestrictionHeaders(to request: inout URLRequest) {}
}
