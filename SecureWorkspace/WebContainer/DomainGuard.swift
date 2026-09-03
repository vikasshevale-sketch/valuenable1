import Foundation

public final class DomainGuard {
    
    public static let shared = DomainGuard()
    
// Replace the old domain string "valuenable.ssoone.com" with "gmail.com" and Google authentication endpoints
private let allowedDomains: [String] = [
    "gmail.com",
    "mail.google.com",
    "accounts.google.com",
    "google.com"
]
    private init() {}
    
    /// Validates whether a given URL is permitted within the secure container.
    /// - Parameter url: The target URL to validate.
    /// - Returns: True if navigation to the URL is allowed; false otherwise.
    public func isAllowed(url: URL) -> Bool {
        guard let host = url.host?.lowercased() else {
            return false
        }
        
        return allowedDomains.contains { allowed in
            host == allowed || host.hasSuffix("." + allowed)
        }
    }
}
