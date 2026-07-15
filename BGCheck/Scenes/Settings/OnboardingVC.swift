import UIKit

class OnboardingVC: UIViewController, KeyboardHandler {
    // MARK: - Public Properties
    var keyboardWillShowAction: ((Notification) -> Void)?
    var keyboardWillHideAction: ((Notification) -> Void)?
    
    // MARK: - Private Properties
    private let viewModel = OnboardingVM()
    
    private let coatOfArmsPicture: UIImageView = UIImageView(image: .onboardingVCCoatOfArms)
    private let casesView = UIView()
    private let addCaseButton = UIButton(type: .system)
    private let remindButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private let casesTable = UITableView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupKeyboardActions()
        hideKeyboardWhenTappedAround()
        setupCasesTableView()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        setupKeyboardHandling()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardHandling()
    }
        
    // MARK: - Actions
    @objc private func addCaseButtonPressed() {
        viewModel.addCase()
    }
    
    @objc private func addReminderButtonPressed() {
        let settingsVC = ReminderSettingsVC(
            weekDays: viewModel.getWeekDays(),
            storedSettings: viewModel.getStoredNotificationSettings()
        )
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
    
    private func setupCasesTableView() {
        casesTable.backgroundColor = .clear
        casesTable.delegate = self
        casesTable.dataSource = self
        casesTable.showsVerticalScrollIndicator = false
        casesTable.register(OnboardingTableCell.self, forCellReuseIdentifier: OnboardingTableCell.reuseIdentifier)
        casesTable.separatorStyle = .none
        casesTable.allowsSelection = false
    }
    
    private func setupUI() {
        view.overrideUserInterfaceStyle = .light
        view.backgroundColor = .backgroundPrimary
        
        configureAddCasesView()
        configureDoneButton()
        
        [coatOfArmsPicture, casesView, casesTable, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [casesView, casesTable].forEach {
            $0.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                        constant: .spacing20
            ).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                         constant: -.spacing20
            ).isActive = true
        }
        
        NSLayoutConstraint.activate([
            coatOfArmsPicture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .spacing10),
            coatOfArmsPicture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coatOfArmsPicture.heightAnchor.constraint(equalToConstant: .coatOfArmsDimension180),
            coatOfArmsPicture.heightAnchor.constraint(equalTo: coatOfArmsPicture.widthAnchor),
            
            casesView.topAnchor.constraint(equalTo: coatOfArmsPicture.bottomAnchor, constant: .spacing10),
            casesView.heightAnchor.constraint(equalToConstant: .buttonsHeight48),
            
            casesTable.topAnchor.constraint(equalTo: casesView.bottomAnchor, constant: .spacing10),
            
            doneButton.topAnchor.constraint(equalTo: casesTable.bottomAnchor, constant: .spacing10),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.spacing4),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: .buttonsWidth240),
            doneButton.heightAnchor.constraint(equalToConstant: .buttonsHeight48)
        ])
    }
    
    private func configureAddCasesView() {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .buttonsLabelFontPrimary
        label.textColor = .black
        label.text = .Localized.onboardingVCLabelCases
        
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
            addCaseButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: .spacing10),
            addCaseButton.widthAnchor.constraint(equalToConstant: .buttonsWidth120),
            addCaseButton.heightAnchor.constraint(equalToConstant: .buttonsHeight48),
            remindButton.trailingAnchor.constraint(equalTo: casesView.trailingAnchor),
            remindButton.leadingAnchor.constraint(equalTo: addCaseButton.trailingAnchor, constant: .spacing10),
            remindButton.widthAnchor.constraint(equalToConstant: .buttonsWidth60),
            remindButton.heightAnchor.constraint(equalToConstant: .buttonsHeight48)
        ])
    }
    
    private func configureAddCaseButton() {
        addCaseButton.backgroundColor = .clear
        addCaseButton.layer.borderWidth = .borderWidth2
        addCaseButton.layer.borderColor = UIColor.buttonsPrimary.cgColor
        addCaseButton.layer.cornerRadius = .cornerRadius16
        addCaseButton.layer.masksToBounds = true
        addCaseButton.clipsToBounds = true
        addCaseButton.setTitleColor(.buttonsPrimary, for: .normal)
        addCaseButton.setTitle(.Localized.onboardingVCButtonAddNewCase, for: .normal)
        addCaseButton.titleLabel?.font = .buttonsLabelFontPrimary
        addCaseButton.addTarget(self, action: #selector(addCaseButtonPressed), for: .touchUpInside)
    }
    
    private func configureRemindButton() {
        remindButton.backgroundColor = .clear
        remindButton.layer.borderWidth = .borderWidth2
        remindButton.layer.cornerRadius = .cornerRadius16
        remindButton.layer.masksToBounds = true
        remindButton.clipsToBounds = true
        remindButton.addTarget(self, action: #selector(addReminderButtonPressed), for: .touchUpInside)
    }
    
    private func configureDoneButton() {
        doneButton.backgroundColor = .clear
        doneButton.layer.borderWidth = .borderWidth2
        doneButton.layer.borderColor = UIColor.buttonsPrimary.cgColor
        doneButton.layer.cornerRadius = .cornerRadius16
        doneButton.layer.masksToBounds = true
        doneButton.clipsToBounds = true
        doneButton.setTitleColor(.buttonsPrimary, for: .normal)
        doneButton.setTitle(.Localized.onboardingVCButtonDone, for: .normal)
        doneButton.titleLabel?.font = .buttonsLabelFontPrimary
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    }
    
    private func addItem(at indexPath: IndexPath) {
        casesTable.performBatchUpdates {
            casesTable.insertRows(at: [indexPath], with: .automatic)
        } completion: { _ in
            self.casesTable.reloadData()
        }
    }
    
    private func removeItem(at indexes: [IndexPath]) {
        casesTable.performBatchUpdates {
            casesTable.deleteRows(at: indexes, with: .automatic)
        } completion: { _ in
            self.casesTable.reloadData()
        }
    }
    
    private func switchToMainView() {
        guard let window = self.view.window else { fatalError("Invalid Configuration") }
        window.rootViewController = WebViewVC()
    }
    
    private func updateAddButtonState() {
        addCaseButton.isHidden = !viewModel.getAddButtonState()
    }
    
    private func updateRemindButtonState(isOn: Bool) {
        switch isOn {
        case true:
            remindButton.setImage(.onboardingVCRemindButtonActive, for: .normal)
            remindButton.layer.borderColor = .buttonsSecondaryCGC
            remindButton.tintColor = .buttonsSecondary
            
        case false:
            remindButton.setImage(.onboardingVCRemindButtonInactive, for: .normal)
            remindButton.layer.borderColor = .buttonsPrimaryCGC
            remindButton.tintColor = .buttonsPrimary
        }
    }
    
    private func setupKeyboardActions() {
        keyboardWillShowAction = { [weak self] notification in
            guard let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                  let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else { return }
            
            let keyboardHeight = keyboardFrame.height
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight - .buttonsHeight48, right: 0)
            
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve)) {
                self?.casesTable.contentInset = contentInsets
                self?.casesTable.scrollIndicatorInsets = contentInsets
            }
        }
        
        keyboardWillHideAction = { [weak self] notification in
            guard let userInfo = notification.userInfo,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                  let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else { return }
            
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve)) {
                self?.casesTable.contentInset = .zero
                self?.casesTable.scrollIndicatorInsets = .zero
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension OnboardingVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.casesCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        .cellHeight85
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
                                               title: .Localized.onboardingVCButtonDelete) { [weak self] (action, view, completionHandler) in
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
        return newLength <= .maxTextLength22
    }
}
