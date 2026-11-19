import UIKit

protocol KeyboardToolbarDelegate: AnyObject {
    func toolbarDidTapLanguage()
    func toolbarDidTapNumberToggle()
    func toolbarDidTapClipboard()
    func toolbarDidTapAI()
    func toolbarDidTapVoice()
}

final class KeyboardToolbar: UIView {
    weak var delegate: KeyboardToolbarDelegate?
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
        let buttons: [(String, Selector)] = [
            ("🌐 Bangla", #selector(langTapped)),
            ("🔢 123", #selector(numTapped)),
            ("📋 Clip", #selector(clipTapped)),
            ("✨ AI", #selector(aiTapped)),
            ("🎙️ Voice", #selector(voiceTapped))
        ]
        for (title, action) in buttons {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            button.addTarget(self, action: action, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
    }

    func applyTheme(_ theme: KeyboardTheme) {
        backgroundColor = theme.toolbarBackground
        stack.arrangedSubviews.compactMap { $0 as? UIButton }.forEach {
            $0.setTitleColor(theme.toolbarText, for: .normal)
        }
    }

    @objc private func langTapped() { delegate?.toolbarDidTapLanguage() }
    @objc private func numTapped() { delegate?.toolbarDidTapNumberToggle() }
    @objc private func clipTapped() { delegate?.toolbarDidTapClipboard() }
    @objc private func aiTapped() { delegate?.toolbarDidTapAI() }
    @objc private func voiceTapped() { delegate?.toolbarDidTapVoice() }
}
