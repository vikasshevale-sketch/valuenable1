import Foundation

// JSON contract shared with the Valuenable enrollment backend
// (reference implementation: backend/server.js in this repository).

/// Device fingerprint sent with an enrollment request. Used by the
/// backend for audit records and to bind the approval token to this
/// specific device.
public struct EnrollmentDeviceInfo: Codable {
    public let deviceModel: String
    public let osVersion: String
    public let appVersion: String
    public let deviceIdentifier: String

    public init(deviceModel: String, osVersion: String, appVersion: String, deviceIdentifier: String) {
        self.deviceModel = deviceModel
        self.osVersion = osVersion
        self.appVersion = appVersion
        self.deviceIdentifier = deviceIdentifier
    }
}

public struct EnrollRequest: Codable {
    public let corporateEmail: String
    public let device: EnrollmentDeviceInfo

    public init(corporateEmail: String, device: EnrollmentDeviceInfo) {
        self.corporateEmail = corporateEmail
        self.device = device
    }
}

public struct EnrollResponse: Codable {
    public let requestId: String
    public let status: String
}

public struct ApprovalStatus: Codable {
    public let requestId: String
    /// "pending" | "approved" | "denied" | "expired"
    public let status: String
    /// Delivered only once the request is approved. Contains the
    /// IMAP/SMTP endpoints and the per-device credentials provisioned
    /// by the IT backend — the user never types a mail password.
    public let mailAccount: MailAccountCredentials?
}

public struct MailAccountCredentials: Codable {
    public let imapHost: String
    public let imapPort: Int
    public let smtpHost: String
    public let smtpPort: Int
    public let username: String
    /// Per-device app password provisioned by the IT backend.
    public let password: String
    public let senderName: String

    public init(imapHost: String, imapPort: Int,
                smtpHost: String, smtpPort: Int,
                username: String, password: String, senderName: String) {
        self.imapHost = imapHost
        self.imapPort = imapPort
        self.smtpHost = smtpHost
        self.smtpPort = smtpPort
        self.username = username
        self.password = password
        self.senderName = senderName
    }
}

public struct AuditEvent: Codable {
    public let deviceIdentifier: String
    public let corporateEmail: String?
    public let type: String
    public let details: String
    public let timestamp: Date
}
