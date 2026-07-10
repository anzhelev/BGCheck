import UIKit

protocol OnboardingTableCellDelegate: AnyObject {
    func historyButtonTapped(for row: Int)
    func caseNameChanged(to newName: String, for row: Int)
    func caseNumberChanged(to newName: String, for row: Int)
    func pinChanged(to newAge: String, for row: Int)
}

final class OnboardingTableCell: UITableViewCell {
    
    // MARK: - Constants

    
    // MARK: - Public Properties
    static let reuseIdentifier = "mainTableCell"
    weak var delegate: OnboardingTableCellDelegate?
    
    // MARK: - Private Properties
    private lazy var caseNameTextField: UITextField = createTextField(
        placeholder: "Enter name",
        action: #selector(
            didChangeCaseNameTextField
        )
    )
    private lazy var caseNumberTextField: UITextField = createTextField(
        placeholder: "Enter number",
        action: #selector(
            didChangeCaseNumberTextField
        )
    )
    private lazy var pinTextField: UITextField = createTextField(
        placeholder: "Enter pin",
        action: #selector(
            didChangePinTextField
        )
    )
    private lazy var historyButton = {
        let button = UIButton(type: .system)
        button.tintColor = .buttonsPrimary
        button.setImage(UIImage(systemName: "text.pad.header.badge.clock.rtl"), for: .normal)
        button.addTarget(self, action: #selector(didTapHistoryButton), for: .touchUpInside)
        return button
    }()
    
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
        self.selectionStyle = .none
        self.row = params.row
        self .caseNameTextField.text = params.caseName
        self.caseNumberTextField.text = params.caseNumber
        self.pinTextField.text = params.pin
    }
    
    // MARK: - Actions
    @objc private func didTapHistoryButton() {
        delegate?.historyButtonTapped(for: row)
    }
    
    @objc private func didChangeCaseNameTextField() {
        delegate?.caseNameChanged(to: caseNameTextField.text ?? "", for: row)
    }
    
    @objc private func didChangeCaseNumberTextField() {
        delegate?.caseNumberChanged(to: caseNumberTextField.text ?? "", for: row)
    }
    
    @objc private func didChangePinTextField() {
        delegate?.pinChanged(to: pinTextField.text ?? "", for: row)
    }
    
    // MARK: - Private Methods
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIConstants.buttonsLabelFontSecondary
        label.textColor = .textPrimary
        label.textAlignment = .right
        label.text = text
        return label
    }
    
    private func createTextField(placeholder: String, action: Selector) -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.textAlignment = .left
        textField.delegate = self
//        textField.addPadding(left: 6, right: 6)
        textField.font = UIConstants.buttonsLabelFontTertiary
        textField.textColor = .textPrimary
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.swipeActionBg.withAlphaComponent(0.3)]
        )
        textField.addTarget(self, action: action, for: .editingDidEnd)
        return textField
    }
    
    private func createHStack(arrangedSubviews: [UIView], spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = spacing
        return stackView
    }
    
    private func createVStack(arrangedSubviews: [UIView], spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = spacing
        return stackView
    }
    
    private func setUIElements() {
        self.backgroundColor = .clear

        let caseNameStackView = createHStack(
            arrangedSubviews: [createLabel(text: UIConstants.caseNameLabelText),
                               caseNameTextField
                              ],
            spacing: UIConstants.textLabelSpacing
        )
        
        let caseNumberStackView = createHStack(
            arrangedSubviews: [createLabel(text: UIConstants.caseNumberLabelText),
                               caseNumberTextField
                              ],
            spacing: UIConstants.textLabelSpacing
        )
        
        let pinStackView = createHStack(
            arrangedSubviews: [createLabel(text: UIConstants.pinLabelText),
                               pinTextField
                              ],
            spacing: UIConstants.textLabelSpacing
        )
        
        let mainVStack = createVStack(
            arrangedSubviews: [
                caseNameStackView,
                caseNumberStackView,
                pinStackView
            ],
            spacing: UIConstants.textLabelSpacing
        )
        
        let mainHStack = createHStack(
            arrangedSubviews: [mainVStack,
                               historyButton
                              ],
            spacing: UIConstants.textLabelSpacing
        )
        
        let mainCellView = UIView()
        mainCellView.backgroundColor = .backgroundSecondary
        mainCellView.layer.masksToBounds = true
        mainCellView.layer.cornerRadius = UIConstants.tableCellCornerRadius
        mainCellView.layer.borderWidth = 0
        
        [mainCellView, mainHStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        mainCellView.addSubview(mainHStack)
        contentView.addSubview(mainCellView)
    
        NSLayoutConstraint.activate([
            mainCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            mainCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            
            mainVStack.widthAnchor.constraint(equalTo: mainCellView.widthAnchor, multiplier: 0.75),
            mainHStack.topAnchor.constraint(equalTo: mainCellView.topAnchor, constant: 8),
            mainHStack.bottomAnchor.constraint(equalTo: mainCellView.bottomAnchor, constant: -8),
            mainHStack.leadingAnchor.constraint(equalTo: mainCellView.leadingAnchor, constant: 10),
            mainHStack.trailingAnchor.constraint(equalTo: mainCellView.trailingAnchor, constant: -10)
        ])
    }
}

extension OnboardingTableCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= UIConstants.maxTextleLenght
    }
}
