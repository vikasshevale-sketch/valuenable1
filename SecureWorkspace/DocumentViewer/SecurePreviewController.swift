import UIKit
import QuickLook

final class SecurePreviewController: QLPreviewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    private let documentURL: URL

    init(documentURL: URL) {
        self.documentURL = documentURL
        super.init(nibName: nil, bundle: nil)
        self.dataSource = self
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Strip out external sharing options from native viewer bar
        navigationItem.rightBarButtonItems = nil
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentURL as QLPreviewItem
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SandboxedFileManager.shared.purgeTemporaryFiles()
    }
}