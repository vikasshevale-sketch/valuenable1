import Foundation

public struct MailFolder {
    public let name: String
    public let messageCount: Int
    public let unseenCount: Int

    public init(name: String, messageCount: Int, unseenCount: Int) {
        self.name = name
        self.messageCount = messageCount
        self.unseenCount = unseenCount
    }
}

public struct MailMessageHeader {
    public let uid: UInt32
    public let subject: String
    public let sender: String
    public let dateString: String
    public let size: Int

    public init(uid: UInt32, subject: String, sender: String, dateString: String, size: Int) {
        self.uid = uid
        self.subject = subject
        self.sender = sender
        self.dateString = dateString
        self.size = size
    }
}

public struct MailAttachment {
    public let fileName: String
    public let mimeType: String
    public let data: Data

    public init(fileName: String, mimeType: String, data: Data) {
        self.fileName = fileName
        self.mimeType = mimeType
        self.data = data
    }
}

public struct MailContent {
    public let uid: UInt32
    public let subject: String
    public let from: String
    public let to: String
    public let date: String
    public let textBody: String?
    public let htmlBody: String?
    public let attachments: [MailAttachment]

    public init(uid: UInt32, subject: String, from: String, to: String, date: String,
                textBody: String?, htmlBody: String?, attachments: [MailAttachment]) {
        self.uid = uid
        self.subject = subject
        self.from = from
        self.to = to
        self.date = date
        self.textBody = textBody
        self.htmlBody = htmlBody
        self.attachments = attachments
    }
}

public struct OutgoingMessage {
    public var to: [String]
    public var cc: [String]
    public var subject: String
    public var textBody: String
    public var htmlBody: String?
    public var attachments: [MailAttachment]

    public init(to: [String], cc: [String] = [], subject: String,
                textBody: String, htmlBody: String? = nil, attachments: [MailAttachment] = []) {
        self.to = to
        self.cc = cc
        self.subject = subject
        self.textBody = textBody
        self.htmlBody = htmlBody
        self.attachments = attachments
    }

    /// Every recipient across To and Cc.
    public var allRecipients: [String] { to + cc }
}
