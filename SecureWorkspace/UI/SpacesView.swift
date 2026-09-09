import SwiftUI

struct SpacesView: View {
    let spaces: [WorkspaceSpace]
    let accountEmail: String
    var onNewSpace: () -> Void = {}
    var onSelect: (WorkspaceSpace) -> Void = { _ in }

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack {
            WorkspaceTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(spaces) { space in
                            Button { onSelect(space) } label: {
                                SpaceTile(space: space)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    Button(action: onNewSpace) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Space")
                                .font(WorkspaceTheme.bodyBoldFont)
                        }
                        .foregroundColor(WorkspaceTheme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(WorkspaceTheme.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: WorkspaceTheme.cardCorner)
                                .stroke(WorkspaceTheme.accent.opacity(0.35), style: StrokeStyle(lineWidth: 1.2, dash: [5]))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cardCorner))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Spaces")
                .font(WorkspaceTheme.titleFont)
                .foregroundColor(WorkspaceTheme.textPrimary)
            Text(accountEmail)
                .font(WorkspaceTheme.bodyFont)
                .foregroundColor(WorkspaceTheme.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
}

private struct SpaceTile: View {
    let space: WorkspaceSpace

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: space.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(WorkspaceTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 11))

            Text(space.name)
                .font(WorkspaceTheme.bodyBoldFont)
                .foregroundColor(WorkspaceTheme.textPrimary)

            UnreadBadge(count: space.unreadCount)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(WorkspaceTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.tileCorner))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

#Preview {
    SpacesView(spaces: MockWorkspaceData.spaces, accountEmail: "you@valuenable.in")
}
