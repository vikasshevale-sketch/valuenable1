import UIKit

/// Base view controller for every screen in the app. Enforces the
/// BYOD data-flow policy (requirement 3): incoming data (paste) is
/// allowed, outgoing data (copy / cut / share / lookup) is blocked.
///
/// All mail UI view controllers derive from this class, so no screen
/// ever exposes a responder action that exfiltrates content.
open class DLPViewController: UIViewController {

    /// Outgoing-data responder actions that must never be offered.
    /// `paste:` is deliberately NOT in this set — incoming data is
    /// allowed per requirement 3 (and iOS shows the user the standard
    /// paste-permission banner).
    private static let blockedActions: Set<Selector> = [
        #selector(UIResponderStandardEditActions.copy(_:)),
        #selector(UIResponderStandardEditActions.cut(_:)),
        #selector(UIResponderStandardEditActions.share(_:)),
        #selector(UIResponderStandardEditActions.select(_:)),
        #selector(UIResponderStandardEditActions.selectAll(_:)),
        #selector(UIResponderStandardEditActions.lookup(_:)),
        #selector(UIResponderStandardEditActions.define(_:)),
        Selector(("promptForReplaceText:")),
        Selector(("makeTextWritingDirectionRightToLeft:"))
    ]

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if Self.blockedActions.contains(action) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

    public override var canBecomeFirstResponder: Bool { true }
}
