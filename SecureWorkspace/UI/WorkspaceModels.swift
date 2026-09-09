import Foundation

struct InboxItem: Identifiable {
    let id = UUID()
    let sender: String
    let timestamp: String
    let subject: String
    let preview: String
    let isUnread: Bool
}

struct WorkspaceSpace: Identifiable {
    let id = UUID()
    let name: String
    let unreadCount: Int
    let icon: String // SF Symbol name
}

enum ChatDirection {
    case incoming
    case outgoing
}

struct ChatBubble: Identifiable {
    let id = UUID()
    let text: String
    let timestamp: String
    let direction: ChatDirection
    let isRead: Bool
    /// Shown as a small system-style caption under the bubble, e.g.
    /// "Approving in Finance space" — mirrors cross-posting into a Space.
    let contextNote: String?

    init(text: String, timestamp: String, direction: ChatDirection, isRead: Bool = false, contextNote: String? = nil) {
        self.text = text
        self.timestamp = timestamp
        self.direction = direction
        self.isRead = isRead
        self.contextNote = contextNote
    }
}

/// Represents the domain-gate check performed when a user tries to add an
/// account to the device. Only accounts on an allowed workspace domain
/// (e.g. valuenable.in) may be added; anything else is rejected client-side
/// before it ever touches the mail store.
struct WorkAccountCandidate {
    let email: String
    let allowedDomain: String

    var isAllowed: Bool {
        email.lowercased().hasSuffix("@\(allowedDomain.lowercased())")
    }
}

struct SecurityRestriction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}
