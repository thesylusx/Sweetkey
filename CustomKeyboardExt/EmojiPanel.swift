import UIKit

protocol EmojiPanelDelegate: AnyObject {
    func emojiPanelDidSelect(_ emoji: String)
    func emojiPanelDidRequestBackspace()
    func emojiPanelDidRequestSwitchToABC()
    func emojiPanelDidRequestSpace()
}

final class EmojiPanel: UIView {
    weak var delegate: EmojiPanelDelegate?

    private let categories: [(id: String, icon: String, emojis: [String])] = [
        ("Faces", "face.smiling", ["😀","😃","😄","😁","😆","😅","🤣","😂","🙂","🙃","😉","😊","😇","🥰","😍","🤩","😘","😗","😚","😙","😋","😛","😜","🤪","😝","🤑","🤗","🤭","🤫","🤔","🤐","🤨","😐","😑","😶","😏","😒","🙄","😬","🤥","😌","😔","😪","🤤","😴","😷","🤒","🤕","🤢","🤮","🤧","🥵","🥶","🥴","😵","🤯","🤠","🥳","😎","🤓","🧐","😕","😟","🙁","😮","😯","😲","😳","🥺","😦","😧","😨","😰","😥","😢","😭","😱","😖","😣","😞","😓","😩","😫","🥱","😤","😡","😠","🤬","😈","👿","💀","💩"]),
        ("Hearts", "heart.fill", ["❤️","🧡","💛","💚","💙","💜","🖤","🤍","🤎","💔","❣️","💕","💞","💓","💗","💖","💘","💝","💟","♥️","💌","💋"]),
        ("Gestures", "hand.thumbsup.fill", ["👍","👎","👌","✌️","🤞","🤟","🤘","🤙","👈","👉","👆","👇","☝️","✋","🤚","🖐️","🖖","👋","🤝","🙏","💪","🦾","🦵","🦶","👂","🦻","👃","🧠","🦷","👀","👁️","👅","👄","🙌","👏","👐","🤲"]),
        ("Money", "dollarsign.circle.fill", ["৳","₹","$","€","£","¥","₿","💰","💵","💴","💶","💷","💸","💳","🧾","🪙","📈","📉","💹"]),
        ("Objects", "sparkles", ["🎉","🎊","🎈","🎁","🔥","⭐","🌟","✨","💫","⚡","💥","💯","🎯","🏆","🥇","🥈","🥉","⚽","🏀","🎮","🎲","🎵","🎶","🎤","🎧","📱","💻","⌨️","🖥️","🖨️","📷","📹","🎥","📺","📻","⏰","⌚","📅","📆","📌","📎","✂️","🔒","🔓","🔑","💡","🔦","🕯️","🛒","🛍️","🎂","🍰","🍕","🍔","🍟","🍦","☕","🍵","🍺","🍷"]),
        ("Symbols", "asterisk", ["✅","❌","⚠️","❗","❓","‼️","⁉️","♻️","✳️","❇️","©️","®️","™️","🔴","🟠","🟡","🟢","🔵","🟣","⚫","⚪","🟤","🔶","🔷","🔸","🔹","🔺","🔻","▪️","▫️","◾","◽","⬛","⬜","🔈","🔉","🔊","🔇","📢","📣","🔔","🔕"])
    ]

    private var selectedCategoryIndex = 0
    private var theme: KeyboardTheme = ThemeManager.shared.currentTheme
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private let collectionView: UICollectionView
    private let bottomRow = UIStackView()

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setup() {
        clipsToBounds = true
        categoryScroll.showsHorizontalScrollIndicator = false
        categoryScroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoryScroll)
        categoryStack.axis = .horizontal
        categoryStack.spacing = 6
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryScroll.addSubview(categoryStack)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        addSubview(collectionView)
        bottomRow.axis = .horizontal
        bottomRow.spacing = 6
        bottomRow.distribution = .fillProportionally
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomRow)

        let abcBtn = makeBottomButton(title: "ABC")
        abcBtn.addTarget(self, action: #selector(abcTapped), for: .touchUpInside)
        let spaceBtn = makeBottomButton(title: "space")
        spaceBtn.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        let delBtn = makeBottomButton(title: "⌫")
        delBtn.addTarget(self, action: #selector(delTapped), for: .touchUpInside)
        bottomRow.addArrangedSubview(abcBtn)
        bottomRow.addArrangedSubview(spaceBtn)
        bottomRow.addArrangedSubview(delBtn)

        NSLayoutConstraint.activate([
            categoryScroll.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            categoryScroll.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            categoryScroll.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            categoryScroll.heightAnchor.constraint(equalToConstant: 32),
            categoryStack.leadingAnchor.constraint(equalTo: categoryScroll.leadingAnchor),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScroll.trailingAnchor),
            categoryStack.topAnchor.constraint(equalTo: categoryScroll.topAnchor),
            categoryStack.bottomAnchor.constraint(equalTo: categoryScroll.bottomAnchor),
            categoryStack.heightAnchor.constraint(equalTo: categoryScroll.heightAnchor),
            collectionView.topAnchor.constraint(equalTo: categoryScroll.bottomAnchor, constant: 4),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomRow.topAnchor, constant: -4),
            bottomRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            bottomRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            bottomRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            bottomRow.heightAnchor.constraint(equalToConstant: 44)
        ])
        buildCategoryTabs()
    }

    private func buildCategoryTabs() {
        categoryStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, cat) in categories.enumerated() {
            let btn = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            btn.setImage(UIImage(systemName: cat.icon, withConfiguration: config), for: .normal)
            btn.setTitle(" \(cat.id)", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 11, weight: .medium)
            btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
            btn.layer.cornerRadius = 8
            btn.tag = index
            btn.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            categoryStack.addArrangedSubview(btn)
        }
        highlightSelectedCategory()
    }

    private func highlightSelectedCategory() {
        for (index, view) in categoryStack.arrangedSubviews.enumerated() {
            guard let btn = view as? UIButton else { continue }
            let isSelected = index == selectedCategoryIndex
            btn.backgroundColor = isSelected ? theme.accentColor.withAlphaComponent(0.25) : theme.keyBackground.withAlphaComponent(0.4)
            btn.tintColor = isSelected ? theme.accentColor : theme.toolbarText
            btn.setTitleColor(isSelected ? theme.accentColor : theme.toolbarText, for: .normal)
        }
    }

    private func makeBottomButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitleColor(theme.keyText, for: .normal)
        btn.backgroundColor = theme.keyBackground
        btn.layer.cornerRadius = 6
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return btn
    }

    func applyTheme(_ theme: KeyboardTheme) {
        self.theme = theme
        backgroundColor = theme.background
        collectionView.reloadData()
        highlightSelectedCategory()
        for view in bottomRow.arrangedSubviews {
            guard let btn = view as? UIButton else { continue }
            btn.backgroundColor = theme.keyBackground
            btn.setTitleColor(theme.keyText, for: .normal)
        }
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        selectedCategoryIndex = sender.tag
        HapticManager.shared.selectionTap()
        collectionView.reloadData()
        highlightSelectedCategory()
    }

    @objc private func abcTapped() { HapticManager.shared.specialTap(); delegate?.emojiPanelDidRequestSwitchToABC() }
    @objc private func spaceTapped() { HapticManager.shared.keyTap(); delegate?.emojiPanelDidRequestSpace() }
    @objc private func delTapped() { HapticManager.shared.keyTap(); delegate?.emojiPanelDidRequestBackspace() }
}

extension EmojiPanel: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[selectedCategoryIndex].emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.configure(emoji: categories[selectedCategoryIndex].emojis[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 7
        let width = collectionView.bounds.width / columns
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = categories[selectedCategoryIndex].emojis[indexPath.item]
        HapticManager.shared.keyTap()
        delegate?.emojiPanelDidSelect(emoji)
    }
}

final class EmojiCell: UICollectionViewCell {
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(emoji: String) { label.text = emoji }
}
