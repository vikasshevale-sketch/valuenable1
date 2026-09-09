import SwiftUI

/// Shared visual language for the native SecureWorkspace UI (Inbox / Spaces / Chat).
/// Values are pulled from the approved mockup: warm cream backgrounds, a single
/// brick-red/orange accent, white cards, rounded corners.
enum WorkspaceTheme {
    static let background = Color(red: 0.965, green: 0.945, blue: 0.918)   // warm cream
    static let card = Color.white
    static let accent = Color(red: 0.737, green: 0.290, blue: 0.235)       // brick red/orange
    static let accentSoft = Color(red: 0.737, green: 0.290, blue: 0.235).opacity(0.12)
    static let textPrimary = Color(red: 0.145, green: 0.125, blue: 0.106)
    static let textSecondary = Color(red: 0.145, green: 0.125, blue: 0.106).opacity(0.55)
    static let divider = Color.black.opacity(0.06)
    static let danger = Color(red: 0.80, green: 0.22, blue: 0.20)

    static let cardCorner: CGFloat = 16
    static let tileCorner: CGFloat = 18

    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let sectionFont = Font.system(size: 13, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodyBoldFont = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let captionFont = Font.system(size: 12, weight: .medium, design: .rounded)
}

/// Small "Secure · View only" style pill used under nav titles to reinforce
/// that DLP controls are active for the current context.
struct SecurityBadge: View {
    var text: String = "Secure · View only"
    var icon: String = "lock.fill"

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
            Text(text)
                .font(WorkspaceTheme.captionFont)
        }
        .foregroundColor(WorkspaceTheme.accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(WorkspaceTheme.accentSoft)
        .clipShape(Capsule())
    }
}

/// Small unread-count dot + number, reused across inbox rows and space tiles.
struct UnreadBadge: View {
    let count: Int
    var body: some View {
        if count > 0 {
            HStack(spacing: 4) {
                Circle()
                    .fill(WorkspaceTheme.accent)
                    .frame(width: 6, height: 6)
                Text("\(count) unread")
                    .font(WorkspaceTheme.captionFont)
                    .foregroundColor(WorkspaceTheme.textSecondary)
            }
        } else {
            Text("0 unread")
                .font(WorkspaceTheme.captionFont)
                .foregroundColor(WorkspaceTheme.textSecondary.opacity(0.6))
        }
    }
}
