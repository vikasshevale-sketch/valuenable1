import Foundation

public final class DomainGuard {
    
    public static let shared = DomainGuard()
    
    /// Allowed domain host suffixes to permit navigation during Google/Gmail authentication flows.
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
