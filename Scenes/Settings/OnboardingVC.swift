import UIKit

class OnboardingVC: UIViewController {
    
    // MARK: - Constants
    
//    private enum Constants {
//        static let cornerRadius: CGFloat = 6
//        static let borderWidth: CGFloat = 1
//        static let labelFontSize: CGFloat = 15
//        static let valueFontSize: CGFloat = 16
//        static let casesViewHeight: CGFloat = 48
//        static let casesTableCellHeight: CGFloat = 85
//        static let buttonHeight: CGFloat = 48
//        static let doneButtonHeight: CGFloat = 48
//        static let doneButtonWidth: CGFloat = 240
//        static let leadingOffset: CGFloat = 20
//        static let spacing: CGFloat = 10
//        static let smallSpacing: CGFloat = 8
//        static let maxTextLength: Int = 22
//        static let minimumTitleLength = 6
//    }
    
    // MARK: - Private Properties
    private let viewModel = OnboardingViewModel()

    private let coatOfArmsPicture: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BG"))
        return imageView
    }()
    
    private let casesView = UIView()
    private let addCaseButton = UIButton(type: .system)
    private let remindButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private let tableView = UITableView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        hideKeyboardWhenTappedAround()
        setupTableView()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Actions
    @objc private func addCaseButtonPressed() {
        viewModel.addCase()
    }
    
    @objc private func addReminderButtonPressed() {
        let settingsVC = ReminderSettingsVC(storedSettings: viewModel.getStoredNotificationSettings())
        settingsVC.onSave = { settings in
            self.viewModel.updateNotificationSettings(with: settings)
        }
        settingsVC.modalPresentationStyle = .overCurrentContext
        settingsVC.modalTransitionStyle = .crossDissolve
        present(settingsVC, animated: true)
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
                
            case .updateRemindButtonState(let isOn):
                self.updateRemindButtonState(isOn: isOn)
                
            case .showHistory(let row, let userCase):
                let assembler = HistoryViewAssembler(number: row, userCase: userCase)
                let viewController  = assembler.build()
                self.navigationController?.pushViewController(viewController, animated: true)
                
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
//        tableView.separatorInset = UIConstants.tableSeparatorInset
        tableView.register(OnboardingTableCell.self, forCellReuseIdentifier: OnboardingTableCell.reuseIdentifier)
        tableView.separatorStyle = .none
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        configureAddCasesView()
        configureDoneButton()
        
        [coatOfArmsPicture, casesView, tableView, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [casesView, tableView].forEach {
            $0.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                        constant: UIConstants.horizontalUIOffset
            ).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                         constant: -UIConstants.horizontalUIOffset
            ).isActive = true
        }
        
        NSLayoutConstraint.activate([
            coatOfArmsPicture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.topUIOffset),
            coatOfArmsPicture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coatOfArmsPicture.heightAnchor.constraint(equalToConstant: UIConstants.coatOfArmsImageDimension),
            coatOfArmsPicture.heightAnchor.constraint(equalTo: coatOfArmsPicture.widthAnchor),
            
            
            casesView.topAnchor.constraint(equalTo: coatOfArmsPicture.bottomAnchor, constant: UIConstants.verticalUIOffsetPrimary),
            casesView.heightAnchor.constraint(equalToConstant: UIConstants.buttonsHeight),
            
            tableView.topAnchor.constraint(equalTo: casesView.bottomAnchor, constant: UIConstants.verticalUIOffsetPrimary),
            
            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: UIConstants.verticalUIOffsetPrimary),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UIConstants.bottomUIOffset),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: UIConstants.buttonsWidthPrimary),
            doneButton.heightAnchor.constraint(equalToConstant: UIConstants.buttonsHeight)
        ])
    }

    private func configureAddCasesView() {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIConstants.buttonsLabelFontPrimary
        label.textColor = .black
        label.text = UIConstants.addCasesLabelText
        
        configureAddCaseButton()
        configureRemindButton()
        updateAddButtonState()
        updateRemindButtonState(isOn: viewModel.getRemindState())
                
        [label, addCaseButton, remindButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            casesView.addSubview($0)
            
            $0.centerYAnchor.constraint(equalTo: casesView.centerYAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: casesView.leadingAnchor),
            addCaseButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: UIConstants.buttonsSpacing),
            addCaseButton.widthAnchor.constraint(equalToConstant: UIConstants.buttonsWidthSecondary),
            addCaseButton.heightAnchor.constraint(equalToConstant: UIConstants.buttonsHeight),
            remindButton.trailingAnchor.constraint(equalTo: casesView.trailingAnchor),
            remindButton.leadingAnchor.constraint(equalTo: addCaseButton.trailingAnchor, constant: UIConstants.buttonsSpacing),
            remindButton.widthAnchor.constraint(equalToConstant: UIConstants.buttonsWidthTertiary),
            remindButton.heightAnchor.constraint(equalToConstant: UIConstants.buttonsHeight)
        ])
    }
    
    private func configureAddCaseButton() {
        addCaseButton.backgroundColor = .clear
        addCaseButton.layer.borderWidth = UIConstants.buttonsBorderWidthPrimary
        addCaseButton.layer.borderColor = UIColor.buttonsPrimary.cgColor
        addCaseButton.layer.cornerRadius = UIConstants.buttonsCornerRadius
        addCaseButton.layer.masksToBounds = true
        addCaseButton.clipsToBounds = true
        addCaseButton.setTitleColor(.buttonsPrimary, for: .normal)
        addCaseButton.setTitle(UIConstants.addCasesButtonTitle, for: .normal)
        addCaseButton.titleLabel?.font = UIConstants.buttonsLabelFontPrimary
        
        addCaseButton.addTarget(self, action: #selector(addCaseButtonPressed), for: .touchUpInside)
    }
    
    private func configureRemindButton() {
        remindButton.backgroundColor = .clear
        remindButton.layer.borderWidth = UIConstants.buttonsBorderWidthPrimary
        remindButton.layer.cornerRadius = UIConstants.buttonsCornerRadius
        remindButton.layer.masksToBounds = true
        remindButton.clipsToBounds = true
        remindButton.addTarget(self, action: #selector(addReminderButtonPressed), for: .touchUpInside)
    }
    
    private func configureDoneButton() {
        doneButton.backgroundColor = .clear
        doneButton.layer.borderWidth = UIConstants.buttonsBorderWidthPrimary
        doneButton.layer.borderColor = UIColor.buttonsPrimary.cgColor
        doneButton.layer.cornerRadius = UIConstants.buttonsCornerRadius
        doneButton.layer.masksToBounds = true
        doneButton.clipsToBounds = true
        doneButton.setTitleColor(.buttonsPrimary, for: .normal)
        doneButton.setTitle(UIConstants.doneButtonTitle, for: .normal)
        doneButton.titleLabel?.font = UIConstants.buttonsLabelFontPrimary
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
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
    
    private func updateRemindButtonState(isOn: Bool) {
        switch isOn {
        case true:
            remindButton.setImage(UIImage(systemName: UIConstants.remindButtonImageNameSecondary), for: .normal)
            remindButton.layer.borderColor = .buttonsSecondaryCGC
            remindButton.tintColor = .buttonsSecondary
            
            
        case false:
            remindButton.setImage(UIImage(systemName: UIConstants.remindButtonImageNamePrimary), for: .normal)
            remindButton.layer.borderColor = .buttonsPrimaryCGC
            remindButton.tintColor = .buttonsPrimary
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension OnboardingVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.casesCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIConstants.casesTableCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: OnboardingTableCell.reuseIdentifier,
            for: indexPath
        ) as? OnboardingTableCell else {
            return UITableViewCell()
        }
        
        cell.delegate = viewModel as OnboardingTableCellDelegate
        cell.configure(with: viewModel.getCellParams(for: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
  
        let primaryAction = UIContextualAction(style: .destructive,
                                               title: UIConstants.deleteButtonTitle) { [weak self] (action, view, completionHandler) in
            self?.viewModel.deleteButtonTapped(for: indexPath.row)
            completionHandler(true)
        }
        primaryAction.backgroundColor = .swipeActionBg
        
        return UISwipeActionsConfiguration(actions: [primaryAction])
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
        return newLength <= UIConstants.cellsTextFieldsMaxTextLength
    }
}
