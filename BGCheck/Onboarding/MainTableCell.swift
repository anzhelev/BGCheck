import UIKit

protocol MainTableCellDelegate: AnyObject {
    func deleteButtonTapped(for row: Int)
    func caseNameChanged(to newName: String, for row: Int)
    func caseNumberChanged(to newName: String, for row: Int)
    func pinChanged(to newAge: String, for row: Int)
}

final class MainTableCell: UITableViewCell {
    
    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 12
//        static let borderWidth: CGFloat = 0.8
        static let labelFontSize: CGFloat = 15
        static let valueFontSize: CGFloat = 14
//        static let leadingOffset: CGFloat = 10
//        static let trailingOffset: CGFloat = -10
        static let mainHStackSpacing: CGFloat = 20
        static let mainVStackSpacing: CGFloat = 7
        static let spacing: CGFloat = 8
        static let caseNameLabelText: String = "Name:"
        static let caseNumberLabelText: String = "№:"
        static let pinLabelText: String = "Pin:"
        static let maxTextleLenght: Int = 20
    }
    
    // MARK: - Public Properties
    static let reuseIdentifier = "mainTableCell"
    weak var delegate: MainTableCellDelegate?
    
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
        self .caseNameTextField.text = params.caseName
        self.caseNumberTextField.text = params.caseNumber
        self.pinTextField.text = params.pin
//        separatorInset = params.separator
//        ? UIEdgeInsets(top: 0, left: Constants.leadingOffset, bottom: 0, right: Constants.leadingOffset)
//        : UIEdgeInsets(top: 0, left: self.bounds.midX, bottom: 0, right: self.bounds.midX)
    }
    
    // MARK: - Actions
    @objc private func didTapDeleteButton() {
        delegate?.deleteButtonTapped(for: row)
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
        label.font = UIFont.systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        label.textColor = .black
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
        textField.font = .systemFont(ofSize: Constants.valueFontSize, weight: .regular)
        textField.textColor = Colors.textValueColor
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.red.withAlphaComponent(0.3)]
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
            arrangedSubviews: [createLabel(text: Constants.caseNameLabelText),
                               caseNameTextField
                              ],
            spacing: Constants.spacing
        )
        
        let caseNumberStackView = createHStack(
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
        
        let mainVStack = createVStack(
            arrangedSubviews: [
                caseNameStackView,
                caseNumberStackView,
                pinStackView
            ],
            spacing: Constants.mainVStackSpacing
        )
        
        let mainHStack = createHStack(
            arrangedSubviews: [mainVStack,
                               deleteButton
                              ],
            spacing: Constants.mainHStackSpacing
        )
        
        let mainCellView = UIView()
        mainCellView.backgroundColor = .onboardBg
        mainCellView.layer.masksToBounds = true
        mainCellView.layer.cornerRadius = Constants.cornerRadius
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
            mainCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            
            mainVStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            mainHStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainHStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            mainHStack.leadingAnchor.constraint(equalTo: mainCellView.leadingAnchor, constant: 10),
            mainHStack.trailingAnchor.constraint(equalTo: mainCellView.trailingAnchor, constant: -10)
        ])
    }
}

extension MainTableCell: UITextFieldDelegate {

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
        return newLength <= Constants.maxTextleLenght
    }
}
