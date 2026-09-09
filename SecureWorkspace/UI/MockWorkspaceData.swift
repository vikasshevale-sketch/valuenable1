import Foundation

/// Sample data used to drive the UI in previews and until the real
/// Gmail/Chat/Spaces sync layer is wired in. Replace with live data sources
/// once the managed-account backend is connected.
enum MockWorkspaceData {

    static let inboxItems: [InboxItem] = [
        InboxItem(sender: "Maya Chen", timestamp: "9:41 AM",
                  subject: "Q3 roadmap review",
                  preview: "Confirms Thursday 2pm, deck attached", isUnread: true),
        InboxItem(sender: "Linear", timestamp: "8:15 AM",
                  subject: "Your issue was closed",
                  preview: "PROJ-118 marked done by Sam", isUnread: true),
        InboxItem(sender: "Ana Torres", timestamp: "7:32 AM",
                  subject: "Coffee next week?",
                  preview: "Free Tuesday or Wednesday afternoon", isUnread: true),
        InboxItem(sender: "Jordan Patel", timestamp: "Yesterday",
                  subject: "Design system update",
                  preview: "New components for tables and charts", isUnread: false),
        InboxItem(sender: "Priya Shah", timestamp: "Yesterday",
                  subject: "Team offsite notes",
                  preview: "Key takeaways and action items", isUnread: false),
        InboxItem(sender: "System Notifications", timestamp: "Yesterday",
                  subject: "Security digest",
                  preview: "1 new sign-in from macOS", isUnread: false),
    ]

    static let spaces: [WorkspaceSpace] = [
        WorkspaceSpace(name: "Work", unreadCount: 12, icon: "briefcase.fill"),
        WorkspaceSpace(name: "Finance", unreadCount: 5, icon: "banknote.fill"),
        WorkspaceSpace(name: "HR", unreadCount: 2, icon: "person.2.fill"),
        WorkspaceSpace(name: "Projects", unreadCount: 9, icon: "folder.fill"),
        WorkspaceSpace(name: "Leadership", unreadCount: 0, icon: "star.fill"),
        WorkspaceSpace(name: "Alerts", unreadCount: 4, icon: "bell.fill"),
    ]

    static let priyaChat: [ChatBubble] = [
        ChatBubble(text: "Can you check the vendor invoice before 5?",
                   timestamp: "9:31 AM", direction: .incoming),
        ChatBubble(text: "On it, reviewing now",
                   timestamp: "9:32 AM", direction: .outgoing, isRead: true),
        ChatBubble(text: "Numbers match, approving in Finance space",
                   timestamp: "9:34 AM", direction: .incoming),
        ChatBubble(text: "Thanks! Attaching nothing here, all secured docs stay in-app",
                   timestamp: "9:36 AM", direction: .outgoing, isRead: true),
    ]

    static let addAccountRestrictions: [SecurityRestriction] = [
        SecurityRestriction(icon: "camera.fill", title: "Screenshots disabled",
                             subtitle: "For your organization's security"),
        SecurityRestriction(icon: "arrow.down.circle.fill", title: "Downloads disabled",
                             subtitle: "For your organization's security"),
        SecurityRestriction(icon: "square.and.arrow.up.fill", title: "Sharing outside this app disabled",
                             subtitle: "For your organization's security"),
        SecurityRestriction(icon: "doc.on.doc.fill", title: "Copy disabled",
                             subtitle: "For your organization's security"),
    ]

    static let allowedDomain = "valuenable.in"
}
