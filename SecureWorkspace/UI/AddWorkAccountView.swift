import SwiftUI

struct AddWorkAccountView: View {
    let allowedDomain: String
    let restrictions: [SecurityRestriction]
    var onContinue: (WorkAccountCandidate) -> Void = { _ in }
    var onDismiss: () -> Void = {}

    @State private var workEmail: String = ""
    @State private var personalEmail: String = ""

    private var personalCandidate: WorkAccountCandidate {
        WorkAccountCandidate(email: personalEmail, allowedDomain: allowedDomain)
    }

    private var canContinue: Bool {
        let workCandidate = WorkAccountCandidate(email: workEmail, allowedDomain: allowedDomain)
        return !workEmail.isEmpty && workCandidate.isAllowed
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber

            VStack(alignment: .leading, spacing: 6) {
                Text("Add work account")
                    .font(WorkspaceTheme.titleFont)
                    .foregroundColor(WorkspaceTheme.textPrimary)
                Text("Only \(allowedDomain) accounts can be added on this device")
                    .font(WorkspaceTheme.bodyFont)
                    .foregroundColor(WorkspaceTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 18)

            VStack(spacing: 10) {
                AccountField(
                    text: $workEmail,
                    suffix: "@\(allowedDomain)",
                    isValid: true,
                    errorText: nil
                )

                AccountField(
                    text: $personalEmail,
                    suffix: nil,
                    isValid: personalEmail.isEmpty || personalCandidate.isAllowed,
                    errorText: personalEmail.isEmpty || personalCandidate.isAllowed
                        ? nil
                        : "\(personalEmail) isn't allowed on this device"
                )
            }
            .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(restrictions) { restriction in
                        RestrictionRow(restriction: restriction)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
            }

            Button {
                onContinue(WorkAccountCandidate(email: workEmail, allowedDomain: allowedDomain))
            } label: {
                Text("Continue")
                    .font(WorkspaceTheme.bodyBoldFont)
                    .foregroundColor(canContinue ? .white : WorkspaceTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(canContinue ? WorkspaceTheme.accent : WorkspaceTheme.divider)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!canContinue)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(WorkspaceTheme.card.ignoresSafeArea())
    }

    private var grabber: some View {
        Capsule()
            .fill(WorkspaceTheme.divider)
            .frame(width: 40, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 4)
    }
}

private struct AccountField: View {
    @Binding var text: String
    let suffix: String?
    let isValid: Bool
    let errorText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TextField(suffix == nil ? "personal@gmail.com" : "arjun.mehta", text: $text)
                    .font(WorkspaceTheme.bodyFont)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if let suffix {
                    Text(suffix)
                        .font(WorkspaceTheme.bodyFont)
                        .foregroundColor(WorkspaceTheme.textSecondary)
                }

                Image(systemName: isValid ? "lock.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(isValid ? WorkspaceTheme.textSecondary : WorkspaceTheme.danger)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(WorkspaceTheme.background)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isValid ? Color.clear : WorkspaceTheme.danger.opacity(0.6), lineWidth: 1.2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if let errorText {
                Text(errorText)
                    .font(WorkspaceTheme.captionFont)
                    .foregroundColor(WorkspaceTheme.danger)
                    .padding(.horizontal, 4)
            }
        }
    }
}

private struct RestrictionRow: View {
    let restriction: SecurityRestriction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: restriction.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(WorkspaceTheme.textPrimary)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(restriction.title)
                    .font(WorkspaceTheme.bodyBoldFont)
                    .foregroundColor(WorkspaceTheme.textPrimary)
                Text(restriction.subtitle)
                    .font(WorkspaceTheme.captionFont)
                    .foregroundColor(WorkspaceTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(WorkspaceTheme.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(WorkspaceTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AddWorkAccountView(allowedDomain: MockWorkspaceData.allowedDomain,
                        restrictions: MockWorkspaceData.addAccountRestrictions)
}
