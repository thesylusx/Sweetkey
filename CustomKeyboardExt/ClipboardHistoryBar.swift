import UIKit

protocol ClipboardHistoryBarDelegate: AnyObject {
    func clipboardBarDidSelect(_ text: String)
    func clipboardBarDidRequestClear()
}

final class ClipboardHistoryBar: UIView {
    weak var delegate: ClipboardHistoryBarDelegate?
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let clearButton = UIButton(type: .system)

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
        clearButton.setTitle("🗑️", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 16)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(clearButton)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 32)
        ])
    }

    func reload(with items: [String]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in items {
            let button = UIButton(type: .system)
            let preview = item.count > 20 ? String(item.prefix(20)) + "…" : item
            button.setTitle(preview, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
            button.backgroundColor = .secondarySystemBackground
            button.layer.cornerRadius = 6
            button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
    }

    func applyTheme(_ theme: KeyboardTheme) { backgroundColor = theme.clipboardBackground }

    @objc private func itemTapped(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        delegate?.clipboardBarDidSelect(title)
    }

    @objc private func clearTapped() { delegate?.clipboardBarDidRequestClear() }
}
