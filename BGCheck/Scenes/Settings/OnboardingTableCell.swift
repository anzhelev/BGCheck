import UIKit

protocol OnboardingTableCellDelegate: AnyObject {
    func caseNameChanged(to newName: String, for row: Int)
    func caseNumberChanged(to newName: String, for row: Int)
    func historyButtonTapped(for row: Int)
    func pinChanged(to newAge: String, for row: Int)
}

final class OnboardingTableCell: UITableViewCell {

    // MARK: - Public Properties
    weak var delegate: OnboardingTableCellDelegate?
    static let reuseIdentifier = "mainTableCell"

    // MARK: - Private Properties
    private lazy var caseNameTextField: UITextField = createTextField(
        placeholder: .Localized.onboardingVCPlaceholderName,
        action: #selector(didChangeCaseNameTextField)
    )
    private lazy var caseNumberTextField: UITextField = createTextField(
        placeholder: .Localized.onboardingVCPlaceholderNumber,
        action: #selector(didChangeCaseNumberTextField)
    )
    private lazy var historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .buttonsPrimary
        button.setImage(.onboardingVCHistoryButton, for: .normal)
        button.addTarget(self, action: #selector(didTapHistoryButton), for: .touchUpInside)
        return button
    }()
    private lazy var pinTextField: UITextField = createTextField(
        placeholder: .Localized.onboardingVCPlaceholderPin,
        action: #selector(didChangePinTextField)
    )
    private var row: Int = 0

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUIElements()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func configure(with params: OnboardingTableCellParams) {
        selectionStyle = .none
        row = params.row
        caseNameTextField.text = params.caseName
        caseNumberTextField.text = params.caseNumber
        pinTextField.text = params.pin
    }

    // MARK: - Actions
    @objc private func didChangeCaseNameTextField() {
        delegate?.caseNameChanged(to: caseNameTextField.text ?? "", for: row)
    }

    @objc private func didChangeCaseNumberTextField() {
        delegate?.caseNumberChanged(to: caseNumberTextField.text ?? "", for: row)
    }

    @objc private func didChangePinTextField() {
        delegate?.pinChanged(to: pinTextField.text ?? "", for: row)
    }

    @objc private func didTapHistoryButton() {
        delegate?.historyButtonTapped(for: row)
    }

    // MARK: - Private Methods
    private func createHStack(arrangedSubviews: [UIView], spacing: CGFloat) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillProportionally
        stack.spacing = spacing
        return stack
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = .systemFont15Semibold
        label.textColor = .textPrimary
        label.textAlignment = .right
        label.text = text
        return label
    }

    private func createTextField(placeholder: String, action: Selector) -> UITextField {
        let field = UITextField()
        field.backgroundColor = .clear
        field.borderStyle = .none
        field.textAlignment = .left
        field.delegate = self
        field.font = .systemFont14Regular
        field.textColor = .textPrimary
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.swipeActionBg.withAlphaComponent(0.3)]
        )
        field.addTarget(self, action: action, for: .editingDidEnd)
        return field
    }

    private func createVStack(arrangedSubviews: [UIView], spacing: CGFloat) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.spacing = spacing
        return stack
    }

    private func setUIElements() {
        backgroundColor = .clear

        let fieldConfigs: [(label: String, textField: UITextField)] = [
            (.Localized.onboardingVCLabelCaseName, caseNameTextField),
            (.Localized.onboardingVCLabelCaseNumber, caseNumberTextField),
            (.Localized.onboardingVCLabelCasePin, pinTextField)
        ]

        let hStacks = fieldConfigs.map { config in
            createHStack(
                arrangedSubviews: [createLabel(text: config.label), config.textField],
                spacing: .spacing8
            )
        }

        let mainVStack = createVStack(arrangedSubviews: hStacks, spacing: .spacing8)
        let mainHStack = createHStack(
            arrangedSubviews: [mainVStack, historyButton],
            spacing: .spacing8
        )

        let mainCellView = UIView()
        mainCellView.backgroundColor = .backgroundSecondary
        mainCellView.layer.masksToBounds = true
        mainCellView.layer.cornerRadius = .cornerRadius12
        mainCellView.layer.borderWidth = 0

        [mainCellView, mainHStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        mainCellView.addSubview(mainHStack)
        contentView.addSubview(mainCellView)

        NSLayoutConstraint.activate([
            mainCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .spacing2),
            mainCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.spacing3),

            mainVStack.widthAnchor.constraint(equalTo: mainCellView.widthAnchor, multiplier: .multiplier075),
            mainHStack.topAnchor.constraint(equalTo: mainCellView.topAnchor, constant: .spacing8),
            mainHStack.bottomAnchor.constraint(equalTo: mainCellView.bottomAnchor, constant: -.spacing8),
            mainHStack.leadingAnchor.constraint(equalTo: mainCellView.leadingAnchor, constant: .spacing10),
            mainHStack.trailingAnchor.constraint(equalTo: mainCellView.trailingAnchor, constant: -.spacing10)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension OnboardingTableCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= .maxTextlenght20
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
