import SwiftUI

/// Native tab-based UI (Inbox / Spaces / Chat) shown once a valid work
/// account is on the device. This is the target native replacement for the
/// old WKWebView container — see AddWorkAccountView for the domain gate that
/// must pass before this view is ever shown.
struct WorkspaceRootView: View {
    @State private var selectedTab: Tab = .inbox
    @State private var openChatContact: String? = "Priya Nair"
    @State private var showAddAccount = false
    @State private var accountEmail: String

    private let restrictions = MockWorkspaceData.addAccountRestrictions
    private let allowedDomain = MockWorkspaceData.allowedDomain

    enum Tab {
        case inbox, spaces, chat
    }

    init(accountEmail: String = "you@\(MockWorkspaceData.allowedDomain)") {
        _accountEmail = State(initialValue: accountEmail)
    }

    var body: some View {
        VStack(spacing: 0) {
            content
            tabBar
        }
        .background(WorkspaceTheme.background.ignoresSafeArea())
        .sheet(isPresented: $showAddAccount) {
            AddWorkAccountView(allowedDomain: allowedDomain, restrictions: restrictions) { candidate in
                if candidate.isAllowed {
                    accountEmail = candidate.email + "@\(allowedDomain)"
                    showAddAccount = false
                }
            }
            .presentationDetents([.large])
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .inbox:
            InboxView(items: MockWorkspaceData.inboxItems)
        case .spaces:
            SpacesView(spaces: MockWorkspaceData.spaces, accountEmail: accountEmail) {
                showAddAccount = true
            }
        case .chat:
            if let contact = openChatContact {
                ChatDetailView(contactName: contact,
                                statusLine: "Online · Secure · View only",
                                bubbles: MockWorkspaceData.priyaChat) {
                    openChatContact = nil
                }
            } else {
                ChatListPlaceholder { openChatContact = "Priya Nair" }
            }
        }
    }

    private var tabBar: some View {
        HStack {
            TabBarButton(icon: "envelope.fill", label: "Inbox", isSelected: selectedTab == .inbox) {
                selectedTab = .inbox
            }
            Spacer()
            TabBarButton(icon: "square.grid.2x2.fill", label: "Spaces", isSelected: selectedTab == .spaces) {
                selectedTab = .spaces
            }
            Spacer()
            TabBarButton(icon: "bubble.left.and.bubble.right.fill", label: "Chat", isSelected: selectedTab == .chat) {
                selectedTab = .chat
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(WorkspaceTheme.card)
    }
}

private struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? WorkspaceTheme.accent : WorkspaceTheme.textSecondary)
        }
    }
}

private struct ChatListPlaceholder: View {
    let onOpenPriya: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 32))
                .foregroundColor(WorkspaceTheme.accent)
            Text("Secure chats live here")
                .font(WorkspaceTheme.bodyBoldFont)
                .foregroundColor(WorkspaceTheme.textPrimary)
            Button("Open Priya Nair", action: onOpenPriya)
                .font(WorkspaceTheme.bodyFont)
                .foregroundColor(WorkspaceTheme.accent)
            Spacer()
        }
    }
}

#Preview {
    WorkspaceRootView()
}
