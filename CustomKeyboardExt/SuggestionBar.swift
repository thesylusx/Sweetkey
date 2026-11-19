import UIKit

protocol SuggestionBarDelegate: AnyObject {
    func suggestionBarDidSelect(_ suggestion: String)
}

final class SuggestionBar: UIView {
    weak var delegate: SuggestionBarDelegate?
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func update(suggestions: [String]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for suggestion in suggestions {
            let button = UIButton(type: .system)
            button.setTitle(suggestion, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
            button.backgroundColor = .secondarySystemBackground
            button.layer.cornerRadius = 6
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
    }

    func clear() { stack.arrangedSubviews.forEach { $0.removeFromSuperview() } }
    func showLoading() { loadingIndicator.startAnimating(); isUserInteractionEnabled = false }
    func hideLoading() { loadingIndicator.stopAnimating(); isUserInteractionEnabled = true }
    func applyTheme(_ theme: KeyboardTheme) { backgroundColor = theme.suggestionBackground }

    @objc private func tapped(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        delegate?.suggestionBarDidSelect(title)
    }
}
