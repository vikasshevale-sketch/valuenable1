import SwiftUI

struct ChatDetailView: View {
    let contactName: String
    let statusLine: String
    let bubbles: [ChatBubble]
    var onBack: () -> Void = {}

    @State private var draft: String = ""

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 14) {
                    Text("Today")
                        .font(WorkspaceTheme.captionFont)
                        .foregroundColor(WorkspaceTheme.textSecondary)
                        .padding(.top, 8)

                    ForEach(bubbles) { bubble in
                        ChatBubbleView(bubble: bubble)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }

            composer
        }
        .background(WorkspaceTheme.background.ignoresSafeArea())
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(WorkspaceTheme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(contactName)
                    .font(WorkspaceTheme.bodyBoldFont)
                    .foregroundColor(WorkspaceTheme.textPrimary)
                HStack(spacing: 6) {
                    Circle().fill(Color.green).frame(width: 6, height: 6)
                    Text(statusLine)
                        .font(WorkspaceTheme.captionFont)
                        .foregroundColor(WorkspaceTheme.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(WorkspaceTheme.accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(WorkspaceTheme.card)
    }

    private var composer: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.system(size: 13))
                .foregroundColor(WorkspaceTheme.textSecondary)

            TextField("Message \(contactName.split(separator: " ").first.map(String.init) ?? "")...",
                      text: $draft)
                .font(WorkspaceTheme.bodyFont)

            Button {
                draft = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(WorkspaceTheme.accent)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(WorkspaceTheme.card)
        .clipShape(Capsule())
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

private struct ChatBubbleView: View {
    let bubble: ChatBubble

    var body: some View {
        VStack(alignment: bubble.direction == .outgoing ? .trailing : .leading, spacing: 4) {
            HStack {
                if bubble.direction == .outgoing { Spacer(minLength: 40) }

                VStack(alignment: .leading, spacing: 4) {
                    Text(bubble.text)
                        .font(WorkspaceTheme.bodyFont)
                        .foregroundColor(bubble.direction == .outgoing ? .white : WorkspaceTheme.textPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(bubble.direction == .outgoing ? WorkspaceTheme.accent : WorkspaceTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if bubble.direction == .incoming { Spacer(minLength: 40) }
            }

            HStack(spacing: 4) {
                if bubble.direction == .outgoing { Spacer() }
                Text(bubble.timestamp)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(WorkspaceTheme.textSecondary)
                if bubble.direction == .outgoing && bubble.isRead {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(WorkspaceTheme.accent)
                }
                if bubble.direction == .incoming { Spacer() }
            }
        }
        // Long-press copy is intentionally not attached — copy is disabled by policy.
    }
}

#Preview {
    ChatDetailView(contactName: "Priya Nair", statusLine: "Online · Secure · View only",
                   bubbles: MockWorkspaceData.priyaChat)
}
