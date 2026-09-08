import UIKit

final class SecureContainerView: UIView {
    private let textField = UITextField()
    private var secureContainer: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSecureHierarchy()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSecureHierarchy()
    }

    private func setupSecureHierarchy() {
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = false
        addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        if let container = textField.subviews.first(where: { NSStringFromClass(type(of: $0)).contains("TextCanvasView") || NSStringFromClass(type(of: $0)).contains("LayoutCanvasView") }) {
            container.isUserInteractionEnabled = true
            self.secureContainer = container
        } else if let lastSubview = textField.subviews.last {
            lastSubview.isUserInteractionEnabled = true
            self.secureContainer = lastSubview
        }
    }

    func addContentView(_ view: UIView) {
        guard let container = secureContainer else {
            addSubview(view)
            return
        }
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }
}