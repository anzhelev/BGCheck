import UIKit

class OnboardingVC: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let labelFontSize: CGFloat = 15
        static let valueFontSize: CGFloat = 16
        static let cellHeight: CGFloat = 60
        static let buttonHeight: CGFloat = 44
        static let resetButtonHeight: CGFloat = 48
        static let resetButtonWidth: CGFloat = 240
        static let leadingOffset: CGFloat = 20
        static let spacing: CGFloat = 10
        static let smallSpacing: CGFloat = 8
        static let maxTextLength: Int = 22
        static let minimumTitleLength = 6
    }
    
    // MARK: - Private Properties
    private let viewModel = OnboardingViewModel()

    private let coatOfArmsPicture: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BG"))
        return imageView
    }()
    
    private let casesView = UIView()
    private let addCaseButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let tableView = UITableView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        hideKeyboardWhenTappedAround()
        setupTableView()
        setupUI()
    }
    
    // MARK: - Actions
    @objc private func addCaseButtonPressed() {
        viewModel.addCase()
    }
    
    @objc private func doneButtonPressed() {
        viewModel.confirmButtonPressed()
    }
    
    // MARK: - Private Methods
    private func bindViewModel() {
        viewModel.onboardingVCBinding.bind { [weak self] value in
            guard let self = self else { return }
            
            switch value {
                
            case .addItem(let indexPath):
                self.addItem(at: indexPath)
                self.updateAddButtonState()
                
            case .removeItem(let indexes):
                self.removeItem(at: indexes)
                self.updateAddButtonState()
                
            case .doneButtonAction:
                self.switchToMainView()
                
            default:
                break
            }
        }
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.register(MainTableCell.self, forCellReuseIdentifier: MainTableCell.reuseIdentifier)
        tableView.separatorStyle = .none
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.onboardingBg
        
        configureAddCasesView()
        configureDoneButton()
        
        [coatOfArmsPicture, casesView, tableView, resetButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [casesView, tableView].forEach {
            $0.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingOffset).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.leadingOffset).isActive = true
        }
        
        NSLayoutConstraint.activate([
            coatOfArmsPicture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            coatOfArmsPicture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coatOfArmsPicture.heightAnchor.constraint(equalTo: coatOfArmsPicture.widthAnchor),
            coatOfArmsPicture.heightAnchor.constraint(equalToConstant: 200),
            
            casesView.topAnchor.constraint(equalTo: coatOfArmsPicture.bottomAnchor, constant: Constants.spacing),
            casesView.heightAnchor.constraint(equalToConstant: Constants.cellHeight),
            
            tableView.topAnchor.constraint(equalTo: casesView.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: Constants.resetButtonWidth),
            resetButton.heightAnchor.constraint(equalToConstant: Constants.resetButtonHeight)
        ])
    }

    private func configureAddCasesView() {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.text = "Cases (max. 5)"
        
        configureAddCaseButton()
        
        [label, addCaseButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            casesView.addSubview($0)
            
            $0.centerYAnchor.constraint(equalTo: casesView.centerYAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: casesView.leadingAnchor),
            addCaseButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: Constants.smallSpacing),
            addCaseButton.trailingAnchor.constraint(equalTo: casesView.trailingAnchor),
            addCaseButton.widthAnchor.constraint(equalToConstant: 162),
            addCaseButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    private func configureAddCaseButton() {
        addCaseButton.backgroundColor = .clear
        addCaseButton.layer.borderWidth = 2
        addCaseButton.layer.borderColor = UIColor.systemBlue.cgColor
        addCaseButton.layer.cornerRadius = 22
        addCaseButton.layer.masksToBounds = true
        addCaseButton.clipsToBounds = true
        addCaseButton.addTarget(self, action: #selector(addCaseButtonPressed), for: .touchUpInside)
        
        let iconImageView = UIImageView(image: UIImage(systemName: "plus")?.withTintColor(.systemBlue))
        
        let buttonLabel = UILabel()
        buttonLabel.text = "Add new case"
        buttonLabel.textColor = .systemBlue
        buttonLabel.textAlignment = .right
        buttonLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        [iconImageView, buttonLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addCaseButton.addSubview($0)
            $0.centerYAnchor.constraint(equalTo: addCaseButton.centerYAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: addCaseButton.leadingAnchor, constant: 10),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            buttonLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor),
            buttonLabel.trailingAnchor.constraint(equalTo: addCaseButton.trailingAnchor, constant: -10)
        ])
    }
    
    private func configureDoneButton() {
        resetButton.backgroundColor = .clear
        resetButton.layer.borderWidth = 2
        resetButton.layer.borderColor = UIColor.systemBlue.cgColor
        resetButton.layer.cornerRadius = 24
        resetButton.layer.masksToBounds = true
        resetButton.clipsToBounds = true
        resetButton.setTitleColor(.systemBlue, for: .normal)
        resetButton.setTitle("Done", for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        resetButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    }
    
    private func addItem(at indexPath: IndexPath) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: [indexPath], with: .automatic)
        } completion: { _ in
            self.tableView.reloadData()
        }
    }
    
    private func removeItem(at indexes: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.deleteRows(at: indexes, with: .automatic)
        } completion: { _ in
            self.tableView.reloadData()
        }
    }
    
    private func switchToMainView() {
        guard let window = self.view.window else { fatalError("Invalid Configuration") }
        window.rootViewController = MainViewController()
    }
    
    private func updateAddButtonState() {
        addCaseButton.isHidden = !viewModel.getAddButtonState()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension OnboardingVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.casesCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MainTableCell.reuseIdentifier,
            for: indexPath
        ) as? MainTableCell else {
            return UITableViewCell()
        }
        
        cell.delegate = viewModel as MainTableCellDelegate
        cell.configure(with: viewModel.getCellParams(for: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension OnboardingVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= Constants.maxTextLength
    }
}
