import UIKit

protocol MainTableCellDelegate: AnyObject {
    func deleteButtonTapped(for row: Int)
    func caseNumberChanged(to newName: String, for row: Int)
    func pinChanged(to newAge: String, for row: Int)
}

final class MainTableCell: UITableViewCell {
    
    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 0.8
        static let labelFontSize: CGFloat = 14
        static let valueFontSize: CGFloat = 15
        static let leadingOffset: CGFloat = 10
        static let trailingOffset: CGFloat = -10
        static let mainStackSpacing: CGFloat = 16
        static let spacing: CGFloat = 6
        static let caseNumberLabelText: String = "№:"
        static let pinLabelText: String = "Pin:"
    }
    
    // MARK: - Public Properties
    static let reuseIdentifier = "mainTableCell"
    weak var delegate: MainTableCellDelegate?
    
    // MARK: - Private Properties
    private lazy var caseNumberTextField: UITextField = createTextField(placeholder: "Enter number", action: #selector(didChangeCaseNumberTextField))
    private lazy var pinTextField: UITextField = createTextField(placeholder: "Enter pin", action: #selector(didChangePinTextField))
    private lazy var deleteButton = {
        let button = UIButton(type: .system)
        button.tintColor = .red
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
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
    func configure(with params: MainTableCellParams) {
        self.selectionStyle = .none
        self.row = params.row
        self.caseNumberTextField.text = params.caseNumber
        self.pinTextField.text = params.pin
        separatorInset = params.separator
        ? UIEdgeInsets(top: 0, left: Constants.leadingOffset, bottom: 0, right: Constants.leadingOffset)
        : UIEdgeInsets(top: 0, left: self.bounds.midX, bottom: 0, right: self.bounds.midX)
    }
    
    // MARK: - Actions
    @objc private func didTapDeleteButton() {
        delegate?.deleteButtonTapped(for: row)
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
        label.font = UIFont.systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .right
        label.text = text
        return label
    }
    
    private func createTextField(placeholder: String, action: Selector) -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = Constants.borderWidth
        textField.textAlignment = .left
        textField.addPadding(left: 6, right: 6)
        textField.font = .systemFont(ofSize: Constants.valueFontSize, weight: .regular)
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.red.withAlphaComponent(0.5)]
        )
        textField.addTarget(self, action: action, for: .editingDidEnd)
        return textField
    }
    
    private func createHStack(arrangedSubviews: [UIView], spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = spacing
        return stackView
    }
    
    private func setUIElements() {
        self.backgroundColor = .clear
        
        let caseNameStackView = createHStack(
            arrangedSubviews: [createLabel(text: Constants.caseNumberLabelText),
                               caseNumberTextField
                              ],
            spacing: Constants.spacing
        )
        
        let pinStackView = createHStack(
            arrangedSubviews: [createLabel(text: Constants.pinLabelText),
                               pinTextField
                              ],
            spacing: Constants.spacing
        )
        
        let mainHStack = createHStack(
            arrangedSubviews: [caseNameStackView,
                               pinStackView,
                               deleteButton
                              ],
            spacing: Constants.mainStackSpacing
        )
        
        mainHStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainHStack)
        
        NSLayoutConstraint.activate([
            mainHStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mainHStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            mainHStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        ])
    }
}
