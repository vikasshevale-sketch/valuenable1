import UIKit
import SwiftUI

/// Thin UIHostingController wrapper so the new native SwiftUI UI
/// (WorkspaceRootView) can be dropped in as a UIKit view controller —
/// e.g. as an alternative root to SecureWebViewController in SceneDelegate,
/// once the account is on an allowed domain.
final class WorkspaceHostingController: UIHostingController<WorkspaceRootView> {
    init(accountEmail: String) {
        super.init(rootView: WorkspaceRootView(accountEmail: accountEmail))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/*
 Integration note (SceneDelegate.swift):

 To make this the app's root instead of the WKWebView container, swap:

     let rootVC = SecureWebViewController()

 for:

     let rootVC = WorkspaceHostingController(accountEmail: currentAccountEmail)

 This intentionally isn't wired in automatically — the existing jailbreak
 check, biometric-lock privacy mask, and background/foreground handling in
 SceneDelegate all still apply and should wrap whichever root view controller
 is active.
*/
