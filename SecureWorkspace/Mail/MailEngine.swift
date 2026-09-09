import Foundation

public enum MailEngineError: LocalizedError {
    case notConfigured
    case connectionFailed(String)
    case protocolError(String)
    case timedOut

    public var errorDescription: String? {
        switch self {
        case .notConfigured: return "No mail account is configured on this device."
        case let .connectionFailed(detail): return "Mail server connection failed: \(detail)"
        case let .protocolError(detail): return "Mail protocol error: \(detail)"
        case .timedOut: return "The mail server did not respond in time."
        }
    }
}

/// Outgoing mail policy (requirements 1 & 3): the MDM controls whether
/// SMTP sending is allowed at all, which recipient domains are
/// permitted, and whether attachments may be attached to new mail.
public struct SendPolicy {
    public let allowOutgoingMail: Bool
    public let allowedRecipientDomains: [String]
    public let allowAttachmentsInCompose: Bool

    public init(allowOutgoingMail: Bool, allowedRecipientDomains: [String], allowAttachmentsInCompose: Bool) {
        self.allowOutgoingMail = allowOutgoingMail
        self.allowedRecipientDomains = allowedRecipientDomains
        self.allowAttachmentsInCompose = allowAttachmentsInCompose
    }

    public static func from(_ configuration: ManagedAppConfiguration) -> SendPolicy {
        SendPolicy(allowOutgoingMail: configuration.allowOutgoingMail,
                   allowedRecipientDomains: configuration.allowedRecipientDomains,
                   allowAttachmentsInCompose: configuration.allowAttachmentsInCompose)
    }

    public enum Violation: LocalizedError {
        case outgoingDisabled
        case recipientDomainNotAllowed(String)
        case attachmentsNotAllowed

        public var errorDescription: String? {
            switch self {
            case .outgoingDisabled:
                return "Sending mail is disabled by company policy."
            case let .recipientDomainNotAllowed(address):
                return "Company policy restricts sending to external addresses (\(address))."
            case .attachmentsNotAllowed:
                return "Attaching files to new mail is disabled by company policy."
            }
        }
    }

    /// Recipient domain check (case-insensitive). An empty allow-list
    /// means "no domain restriction" — every managed policy that the
    /// IT team configures should list at least the company domain.
    public func isRecipientAllowed(_ address: String) -> Bool {
        guard !allowedRecipientDomains.isEmpty else { return true }
        guard let atRange = address.range(of: "@") else { return false }
        let domain = String(address[atRange.upperBound...]).lowercased()
        return allowedRecipientDomains.contains {
            let allowed = $0.lowercased()
            return domain == allowed || domain.hasSuffix("." + allowed)
        }
    }

    /// Throws a `Violation` when the message breaks policy.
    public func validate(_ message: OutgoingMessage) throws {
        guard allowOutgoingMail else { throw Violation.outgoingDisabled }
        guard allowAttachmentsInCompose || message.attachments.isEmpty else {
            throw Violation.attachmentsNotAllowed
        }
        for recipient in message.allRecipients {
            guard isRecipientAllowed(recipient) else {
                throw Violation.recipientDomainNotAllowed(recipient)
            }
        }
    }
}

/// Abstract mail operations implemented on top of IMAP/IMAPS and
/// SMTP/SMTPS (pure Swift, Apple `Network.framework`, implicit TLS).
public protocol MailEngine: AnyObject {
    func listFolders(completion: @escaping (Result<[MailFolder], Error>) -> Void)
    func fetchMessageList(folder: String, completion: @escaping (Result<[MailMessageHeader], Error>) -> Void)
    func fetchMessage(uid: UInt32, folder: String, completion: @escaping (Result<MailContent, Error>) -> Void)
    func send(_ message: OutgoingMessage, completion: @escaping (Result<Void, Error>) -> Void)
    func disconnect()
}
