import SwiftUI

struct InboxView: View {
    let items: [InboxItem]
    var onCompose: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WorkspaceTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(items) { item in
                            InboxRow(item: item)
                            Divider().overlay(WorkspaceTheme.divider).padding(.leading, 20)
                        }
                    }
                }
            }

            Button(action: onCompose) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(WorkspaceTheme.accent)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
            }
            .padding(20)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Inbox")
                    .font(WorkspaceTheme.titleFont)
                    .foregroundColor(WorkspaceTheme.textPrimary)
                Spacer()
            }
            HStack(spacing: 10) {
                Text("Work")
                    .font(WorkspaceTheme.bodyBoldFont)
                    .foregroundColor(WorkspaceTheme.accent)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(WorkspaceTheme.accent)
            }
            SecurityBadge()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }
}

private struct InboxRow: View {
    let item: InboxItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(item.isUnread ? WorkspaceTheme.accent : WorkspaceTheme.divider)
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(item.sender)
                        .font(item.isUnread ? WorkspaceTheme.bodyBoldFont : WorkspaceTheme.bodyFont)
                        .foregroundColor(WorkspaceTheme.textPrimary)
                    Spacer()
                    Text(item.timestamp)
                        .font(WorkspaceTheme.captionFont)
                        .foregroundColor(WorkspaceTheme.textSecondary)
                }
                Text(item.subject)
                    .font(item.isUnread ? WorkspaceTheme.bodyBoldFont : WorkspaceTheme.bodyFont)
                    .foregroundColor(WorkspaceTheme.textPrimary)
                Text(item.preview)
                    .font(WorkspaceTheme.bodyFont)
                    .foregroundColor(WorkspaceTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        // Copy/share disabled per DLP policy: no context menu or drag preview.
        .onDrag { NSItemProvider() } // swallow default drag instead of exposing text
    }
}

#Preview {
    InboxView(items: MockWorkspaceData.inboxItems)
}
