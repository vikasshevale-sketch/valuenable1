import UIKit

final class SecureContainerView: UIView {
    private let secureTextField = UITextField()
    private var containerView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSecureContainer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSecureContainer()
    }

    private func setupSecureContainer() {
        secureTextField.isSecureTextEntry = true
        secureTextField.isUserInteractionEnabled = false
        addSubview(secureTextField)
        
        secureTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secureTextField.topAnchor.constraint(equalTo: topAnchor),
            secureTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            secureTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureTextField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // Safely extract the canvas layer without matching hardcoded internal UIKit strings
        if let canvas = secureTextField.subviews.first(where: { $0.description.contains("Canvas") }) {
            canvas.isUserInteractionEnabled = true
            self.containerView = canvas
        } else if let fallbackView = secureTextField.subviews.last {
            fallbackView.isUserInteractionEnabled = true
            self.containerView = fallbackView
        } else {
            self.containerView = self
        }
    }

    func addContentView(_ view: UIView) {
        let target = containerView ?? self
        target.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: target.topAnchor),
            view.bottomAnchor.constraint(equalTo: target.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: target.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: target.trailingAnchor)
        ])
    }
}