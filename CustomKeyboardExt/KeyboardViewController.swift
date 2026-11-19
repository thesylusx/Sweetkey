import UIKit

final class KeyboardViewController: UIInputViewController {
    private let phoneticEngine = BanglaPhoneticEngine()
    private let learnedWords = LearnedWordsManager()
    private let clipboard = ClipboardManager()
    private let aiService = AIService()

    private var isBanglaMode = true
    private var isNumberMode = false
    private var isEmojiMode = false
    private var currentBuffer = ""
    private var shiftEnabled = false
    private var theme: KeyboardTheme = ThemeManager.shared.currentTheme
    private var context: KeyboardContextType = .standard
    private var hasSetupInitialMode = false

    private let toolbar = KeyboardToolbar()
    private let suggestionBar = SuggestionBar()
    private let clipboardBar = ClipboardHistoryBar()
    private let keyStack = UIStackView()
    private let emojiPanel = EmojiPanel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyTheme()
        learnedWords.load()
        clipboard.refreshFromPasteboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        theme = ThemeManager.shared.currentTheme
        applyTheme()
        if !hasSetupInitialMode { setupInitialModeFromContext(); hasSetupInitialMode = true }
        updateSuggestions()
        checkPendingVoiceText()
    }

    private func setupUI() {
        view.backgroundColor = theme.background

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.delegate = self
        view.addSubview(toolbar)

        suggestionBar.translatesAutoresizingMaskIntoConstraints = false
        suggestionBar.delegate = self
        view.addSubview(suggestionBar)

        clipboardBar.translatesAutoresizingMaskIntoConstraints = false
        clipboardBar.delegate = self
        clipboardBar.isHidden = true
        view.addSubview(clipboardBar)

        keyStack.axis = .vertical
        keyStack.spacing = 6
        keyStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyStack)

        emojiPanel.translatesAutoresizingMaskIntoConstraints = false
        emojiPanel.delegate = self
        emojiPanel.isHidden = true
        view.addSubview(emojiPanel)

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),

            suggestionBar.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            suggestionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: 40),

            clipboardBar.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            clipboardBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            clipboardBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            clipboardBar.heightAnchor.constraint(equalToConstant: 44),

            keyStack.topAnchor.constraint(equalTo: clipboardBar.bottomAnchor, constant: 6),
            keyStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            keyStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            keyStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),

            emojiPanel.topAnchor.constraint(equalTo: clipboardBar.bottomAnchor, constant: 6),
            emojiPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            emojiPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            emojiPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4)
        ])

        rebuildKeys()
    }

    private func applyTheme() {
        view.backgroundColor = theme.background
        toolbar.applyTheme(theme)
        suggestionBar.applyTheme(theme)
        clipboardBar.applyTheme(theme)
        emojiPanel.applyTheme(theme)
        rebuildKeys()
    }

    private func setupInitialModeFromContext() {
        context = KeyboardContextDetector.detect(from: textDocumentProxy)
        if context == .numberOnly || context == .phoneNumber {
            isNumberMode = true
            rebuildKeys()
        }
    }

    private func rebuildKeys() {
        keyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if isNumberMode { buildNumberPad() } else { buildQWERTY() }
    }

    private func buildQWERTY() {
        var rows: [[String]] = [
            ["q","w","e","r","t","y","u","i","o","p"],
            ["a","s","d","f","g","h","j","k","l"],
            ["⇧","z","x","c","v","b","n","m","⌫"],
            ["123","😀","space","return"]
        ]
        if context == .email { rows.insert(["@", ".", ".com", "_", "-"], at: 0) }
        else if context == .url { rows.insert(["/", ".", ":", "_", "-"], at: 0) }

        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 5
            rowStack.distribution = .fillProportionally
            for key in row { rowStack.addArrangedSubview(makeKeyButton(title: key)) }
            keyStack.addArrangedSubview(rowStack)
        }

        if let spaceRow = keyStack.arrangedSubviews.last as? UIStackView,
           let spaceBtn = spaceRow.arrangedSubviews.first(where: { ($0 as? UIButton)?.titleLabel?.text == "space" }) {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSpacePan(_:)))
            spaceBtn.addGestureRecognizer(pan)
        }
    }

    private func buildNumberPad() {
        let rows: [[String]] = [["1","2","3"],["4","5","6"],["7","8","9"],["ABC","0","⌫"]]
        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually
            for key in row {
                let btn = makeKeyButton(title: key)
                btn.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
                rowStack.addArrangedSubview(btn)
            }
            keyStack.addArrangedSubview(rowStack)
        }
    }

    private func makeKeyButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        button.setTitleColor(theme.keyText, for: .normal)
        button.backgroundColor = theme.keyBackground
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true

        let specialKeys: Set<String> = ["⌫","⇧","return","123","ABC","😀","space"]
        if specialKeys.contains(title) {
            button.backgroundColor = theme.specialKeyBackground
            button.setTitleColor(theme.specialKeyText, for: .normal)
            if title == "space" {
                button.setTitleColor(theme.keyText, for: .normal)
                button.backgroundColor = theme.keyBackground
            }
        } else if title.count > 1 && title != "space" {
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.backgroundColor = theme.specialKeyBackground
            button.setTitleColor(theme.specialKeyText, for: .normal)
        }

        button.addTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(keyTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func keyTouchDown(_ sender: UIButton) {
        HapticManager.shared.keyTap()
        UIView.animate(withDuration: 0.06, delay: 0, options: [.curveEaseOut]) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            sender.alpha = 0.65
        }
    }

    @objc private func keyTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.10, delay: 0, options: [.curveEaseOut]) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }

    @objc private func keyTapped(_ sender: UIButton) {
        guard let key = sender.titleLabel?.text else { return }
        if isEmojiMode { exitEmojiMode() }

        switch key {
        case "⌫": handleBackspace()
        case "space": commitBuffer(); textDocumentProxy.insertText(" ")
        case "return": commitBuffer(); textDocumentProxy.insertText("\n")
        case "⇧": shiftEnabled.toggle()
        case "123": isNumberMode = true; rebuildKeys()
        case "ABC": isNumberMode = false; rebuildKeys()
        case "😀": enterEmojiMode()
        case "🌐": isBanglaMode.toggle(); updateSuggestions(); rebuildKeys()
        case "@", ".", ".com", "/", ":", "_", "-": textDocumentProxy.insertText(key)
        default:
            if isNumberMode { textDocumentProxy.insertText(key) }
            else { handleCharacterInput(key) }
        }
    }

    private func handleCharacterInput(_ char: String) {
        currentBuffer += char
        updateSuggestions()
    }

    private func handleBackspace() {
        if !currentBuffer.isEmpty { currentBuffer.removeLast(); updateSuggestions() }
        else { textDocumentProxy.deleteBackward() }
    }

    private func enterEmojiMode() {
        isEmojiMode = true
        keyStack.isHidden = true
        emojiPanel.isHidden = false
    }

    private func exitEmojiMode() {
        isEmojiMode = false
        emojiPanel.isHidden = true
        keyStack.isHidden = false
    }

    private func commitBuffer() {
        guard !currentBuffer.isEmpty else { return }
        let converted = phoneticEngine.convert(currentBuffer, language: isBanglaMode ? .bangla : .english)
        textDocumentProxy.insertText(converted)
        learnedWords.record(word: converted, language: isBanglaMode ? .bangla : .english)
        currentBuffer = ""
        suggestionBar.clear()
    }

    private func updateSuggestions() {
        guard !currentBuffer.isEmpty else { suggestionBar.clear(); return }
        let raw = currentBuffer
        let converted = phoneticEngine.convert(raw, language: isBanglaMode ? .bangla : .english)
        var suggestions: [String] = [raw, converted]
        suggestions.append(contentsOf: learnedWords.suggestions(for: raw, language: isBanglaMode ? .bangla : .english))
        suggestions = Array(NSOrderedSet(array: suggestions)) as? [String] ?? suggestions
        suggestionBar.update(suggestions: Array(suggestions.prefix(4)))
    }

    @objc private func handleSpacePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let offset = Int(translation.x / 8)
        guard offset != 0 else { return }
        if offset > 0 { for _ in 0..<offset { textDocumentProxy.adjustTextPosition(byCharacterOffset: 1) } }
        else { for _ in 0..<abs(offset) { textDocumentProxy.adjustTextPosition(byCharacterOffset: -1) } }
        gesture.setTranslation(.zero, in: view)
        HapticManager.shared.selectionTap()
    }

    private func checkPendingVoiceText() {
        guard let pending = SharedVoiceStore.peekPendingVoiceText(), !pending.isEmpty else { return }
        let preview = pending.count > 140 ? String(pending.prefix(140)) + "…" : pending
        let alert = UIAlertController(title: "🎙️ Voice Input", message: "ইনপুট বক্সে যোগ করবেন?\n\n\"\(preview)\"", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "যোগ করুন", style: .default) { [weak self] _ in
            self?.textDocumentProxy.insertText(pending)
            SharedVoiceStore.clearPending()
            HapticManager.shared.success()
        })
        alert.addAction(UIAlertAction(title: "বাতিল", style: .cancel) { _ in SharedVoiceStore.clearPending() })
        present(alert, animated: true)
    }
}

extension KeyboardViewController: KeyboardToolbarDelegate {
    func toolbarDidTapLanguage() { isBanglaMode.toggle(); updateSuggestions(); rebuildKeys() }
    func toolbarDidTapNumberToggle() {
        isNumberMode.toggle()
        if isNumberMode && isEmojiMode { exitEmojiMode() }
        rebuildKeys()
    }
    func toolbarDidTapClipboard() {
        clipboard.refreshFromPasteboard()
        clipboardBar.isHidden.toggle()
        if !clipboardBar.isHidden { clipboardBar.reload(with: clipboard.items) }
    }
    func toolbarDidTapAI() {
        let text = currentBuffer.isEmpty ? (textDocumentProxy.documentContextBeforeInput ?? "") : currentBuffer
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        suggestionBar.showLoading()
        aiService.rewrite(text: text) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.suggestionBar.hideLoading()
                switch result {
                case .success(let output):
                    self.suggestionBar.update(suggestions: [output])
                    HapticManager.shared.success()
                case .failure(let error):
                    self.suggestionBar.update(suggestions: ["AI: \(error.localizedDescription)"])
                    HapticManager.shared.error()
                }
            }
        }
    }
    func toolbarDidTapVoice() {
        guard let url = URL(string: "sweetkey://voice") else { return }
        if let context = extensionContext {
            context.open(url) { [weak self] success in if !success { self?.showFullAccessAlert() } }
        } else { showFullAccessAlert() }
    }
    private func showFullAccessAlert() {
        let alert = UIAlertController(title: "🎙️ Voice Input",
            message: "Sweetkey অ্যাপ খুলতে পারছি না।\n\nSettings → General → Keyboard → Keyboards → Sweetkey → Allow Full Access চালু করুন, তারপর আবার চেষ্টা করুন।",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ঠিক আছে", style: .default))
        present(alert, animated: true)
    }
}

extension KeyboardViewController: SuggestionBarDelegate {
    func suggestionBarDidSelect(_ suggestion: String) {
        textDocumentProxy.insertText(suggestion)
        learnedWords.record(word: suggestion, language: isBanglaMode ? .bangla : .english)
        currentBuffer = ""
        suggestionBar.clear()
        HapticManager.shared.success()
    }
}

extension KeyboardViewController: ClipboardHistoryBarDelegate {
    func clipboardBarDidSelect(_ text: String) {
        textDocumentProxy.insertText(text)
        clipboardBar.isHidden = true
        HapticManager.shared.success()
    }
    func clipboardBarDidRequestClear() { clipboard.clear(); clipboardBar.reload(with: []) }
}

extension KeyboardViewController: EmojiPanelDelegate {
    func emojiPanelDidSelect(_ emoji: String) { textDocumentProxy.insertText(emoji) }
    func emojiPanelDidRequestBackspace() { textDocumentProxy.deleteBackward() }
    func emojiPanelDidRequestSwitchToABC() { exitEmojiMode() }
    func emojiPanelDidRequestSpace() { textDocumentProxy.insertText(" ") }
}
