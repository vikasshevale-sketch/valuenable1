import Foundation
import UIKit

/// Typed view of the managed app configuration pushed by the MDM
/// (AppConfig Community standard: the dictionary arrives in
/// `UserDefaults` under the key `com.apple.managed.configuration`).
public struct ManagedAppConfiguration {
    public let enrollmentEndpoint: URL
    public let auditEndpoint: URL?
    public let imapHost: String
    public let imapPort: Int
    public let smtpHost: String
    public let smtpPort: Int
    public let allowedRecipientDomains: [String]
    public let allowOutgoingMail: Bool
    public let allowAttachmentsInCompose: Bool
    public let requireApprovalForExternalSend: Bool
    public let maxAttachmentPreviewMB: Int
    public let allowedLinkDomains: [String]
    public let screenshotAuditEnabled: Bool

    /// Local-development fallback used by DEBUG builds only, so the app can
    /// run on a simulator with the reference backend at 127.0.0.1:8080.
    /// Release builds refuse to run without real MDM configuration.
    static let debugDefaults = ManagedAppConfiguration(
        enrollmentEndpoint: URL(string: "http://127.0.0.1:8080")!,
        auditEndpoint: URL(string: "http://127.0.0.1:8080/api/audit"),
        imapHost: "",
        imapPort: 993,
        smtpHost: "",
        smtpPort: 465,
        allowedRecipientDomains: ["valuenable.in"],
        allowOutgoingMail: true,
        allowAttachmentsInCompose: false,
        requireApprovalForExternalSend: true,
        maxAttachmentPreviewMB: 25,
        allowedLinkDomains: ["valuenable.in"],
        screenshotAuditEnabled: false
    )
}

/// Reads the MDM-pushed managed app configuration and enforces the
/// "refuse to run when unmanaged" policy (Release builds).
public final class ManagedConfigurationManager {
    public static let shared = ManagedConfigurationManager()
    public static let managedConfigurationKey = "com.apple.managed.configuration"

    private var cachedConfiguration: ManagedAppConfiguration?
    private let cacheLock = NSLock()

    public init() {}

    /// The configuration the MDM pushed, or nil when the app is unmanaged.
    public var configuration: ManagedAppConfiguration? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        if let cachedConfiguration { return cachedConfiguration }
        guard let dictionary = UserDefaults.standard.dictionary(forKey: Self.managedConfigurationKey),
              !dictionary.isEmpty else { return nil }
        guard let parsed = Self.parse(dictionary) else { return nil }
        cachedConfiguration = parsed
        return parsed
    }

    public var isManaged: Bool { configuration != nil }

    /// The configuration the app should operate with. In DEBUG builds
    /// without MDM config this returns local defaults; in Release it
    /// returns nil (caller must block the app).
    public var effectiveConfiguration: ManagedAppConfiguration? {
        if let configuration { return configuration }
        #if DEBUG
        return ManagedAppConfiguration.debugDefaults
        #else
        return nil
        #endif
    }

    static func parse(_ dictionary: [String: Any]) -> ManagedAppConfiguration? {
        guard let endpointString = dictionary["enrollmentEndpoint"] as? String,
              let enrollmentEndpoint = URL(string: endpointString) else { return nil }

        let auditEndpoint = (dictionary["auditEndpoint"] as? String).flatMap(URL.init(string:))
        let imapHost = (dictionary["imapHost"] as? String) ?? ""
        let smtpHost = (dictionary["smtpHost"] as? String) ?? ""

        return ManagedAppConfiguration(
            enrollmentEndpoint: enrollmentEndpoint,
            auditEndpoint: auditEndpoint ?? enrollmentEndpoint.appendingPathComponent("api/audit"),
            imapHost: imapHost,
            imapPort: (dictionary["imapPort"] as? Int) ?? 993,
            smtpHost: smtpHost,
            smtpPort: (dictionary["smtpPort"] as? Int) ?? 465,
            allowedRecipientDomains: (dictionary["allowedRecipientDomains"] as? [String]) ?? ["valuenable.in"],
            allowOutgoingMail: (dictionary["allowOutgoingMail"] as? Bool) ?? true,
            allowAttachmentsInCompose: (dictionary["allowAttachmentsInCompose"] as? Bool) ?? false,
            requireApprovalForExternalSend: (dictionary["requireApprovalForExternalSend"] as? Bool) ?? true,
            maxAttachmentPreviewMB: (dictionary["maxAttachmentPreviewMB"] as? Int) ?? 25,
            allowedLinkDomains: (dictionary["allowedLinkDomains"] as? [String]) ?? ["valuenable.in"],
            screenshotAuditEnabled: (dictionary["screenshotAuditEnabled"] as? Bool) ?? false
        )
    }
}
