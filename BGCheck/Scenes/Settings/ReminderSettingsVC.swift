import UIKit

final class ReminderSettingsVC: UIViewController {

    // MARK: - Constants
    private let pickerHeight: CGFloat = .pickerHeight120

    // MARK: - Public Properties
    var onSave: ((ReminderSettings) -> Void)?

    // MARK: - Private Properties
    private let closeButton = UIButton(type: .system)
    private let enableLabel = UILabel()
    private let enableSwitch = UISwitch()
    private let frequencyLabel = UILabel()
    private let frequencySegmented = UISegmentedControl(items: String.Localized.reminderViewFrequencyOptions)
    private let monthDays: [String] = Array(1...31).map { "\($0)" }
    private let monthlyLabel = UILabel()
    private let monthlyPicker = UIPickerView()
    private let monthlyStack = UIStackView()
    private let saveButton = UIButton(type: .system)
    private var storedSettings: ReminderSettings?
    private let timeLabel = UILabel()
    private let timePicker = UIDatePicker()
    private let timeRowStack = UIStackView()
    private let titleLabel = UILabel()
    private var weekDays: [WeekdayOption] = []
    private let weeklyLabel = UILabel()
    private let weeklyPicker = UIPickerView()
    private let weeklyStack = UIStackView()

    // MARK: - Initializers
    init(weekDays: [WeekdayOption], storedSettings: ReminderSettings) {
        super.init(nibName: nil, bundle: nil)
        self.weekDays = weekDays
        self.storedSettings = storedSettings
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backbroundTertiary
        setupCardView()
        let frequency = ReminderFrequency(rawValue: frequencySegmented.selectedSegmentIndex) ?? .daily
        updateVisibility(for: frequency)
        updateEnabledState()
    }

    // MARK: - Private Methods
    private func setupCardView() {
        let cardView = UIView()
        cardView.backgroundColor = .backgroundSecondary
        cardView.layer.cornerRadius = .cornerRadius16
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            cardView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.8)
        ])
        setupContent(in: cardView)
    }

    private func setupContent(in container: UIView) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = .spacing16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: .spacing20),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: .spacing20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -.spacing20),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -.spacing20)
        ])

        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.distribution = .fillProportionally
        headerStack.alignment = .center

        titleLabel.text = .Localized.reminderViewTitle
        titleLabel.font = .systemFont17Semibold
        titleLabel.textColor = .textPrimary
        titleLabel.textAlignment = .center

        closeButton.setImage(.reminderViewCloseButton, for: .normal)
        closeButton.tintColor = .buttonsPrimary
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(closeButton)
        stack.addArrangedSubview(headerStack)

        let enableStack = UIStackView()
        enableStack.axis = .horizontal
        enableStack.spacing = .spacing10
        enableStack.alignment = .center

        enableLabel.text = .Localized.reminderViewLabelEnabled
        enableLabel.font = .systemFont16Medium
        enableLabel.textColor = .textPrimary

        enableSwitch.isOn = storedSettings?.isEnabled ?? false
        enableSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        enableStack.addArrangedSubview(enableLabel)
        enableStack.addArrangedSubview(UIView())
        enableStack.addArrangedSubview(enableSwitch)
        stack.addArrangedSubview(enableStack)

        timeRowStack.axis = .horizontal
        timeRowStack.spacing = .spacing10
        timeRowStack.alignment = .center
        timeRowStack.distribution = .fill

        timeLabel.text = .Localized.reminderViewLabelSetTime
        timeLabel.font = .systemFont16Medium
        timeLabel.textColor = .textPrimary

        timePicker.preferredDatePickerStyle = .compact
        timePicker.overrideUserInterfaceStyle = .light
        timePicker.datePickerMode = .time
        timePicker.locale = Locale(identifier: .Localized.localeIdentifier)
        timePicker.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        timePicker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timePicker.date = storedSettings?.time ?? Date()

        timeRowStack.addArrangedSubview(timeLabel)
        timeRowStack.addArrangedSubview(timePicker)
        stack.addArrangedSubview(timeRowStack)

        frequencyLabel.text = .Localized.reminderViewLabelSetFrequency
        frequencyLabel.font = .systemFont16Medium
        frequencyLabel.textColor = .textPrimary
        stack.addArrangedSubview(frequencyLabel)

        frequencySegmented.selectedSegmentIndex = storedSettings?.frequency.rawValue ?? ReminderFrequency.daily.rawValue
        frequencySegmented.overrideUserInterfaceStyle = .light
        frequencySegmented.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        stack.addArrangedSubview(frequencySegmented)

        weeklyStack.axis = .vertical
        weeklyStack.spacing = .spacing8
        weeklyStack.isHidden = true

        weeklyLabel.text = .Localized.reminderViewLabelSetDayOfWeek
        weeklyLabel.font = .systemFont16Medium
        weeklyLabel.textColor = .textPrimary

        weeklyPicker.dataSource = self
        weeklyPicker.delegate = self
        let storedWeekday = storedSettings?.weekday ?? .sunday
        let storedWeekdayRow = weekDays.firstIndex { $0.weekday == storedWeekday } ?? 0
        weeklyPicker.selectRow(storedWeekdayRow, inComponent: 0, animated: false)
        weeklyPicker.heightAnchor.constraint(equalToConstant: pickerHeight).isActive = true
        weeklyPicker.overrideUserInterfaceStyle = .light

        weeklyStack.addArrangedSubview(weeklyLabel)
        weeklyStack.addArrangedSubview(weeklyPicker)
        stack.addArrangedSubview(weeklyStack)

        monthlyStack.axis = .vertical
        monthlyStack.spacing = .spacing8
        monthlyStack.isHidden = true

        monthlyLabel.text = .Localized.reminderViewLabelSetDayOfMonth
        monthlyLabel.font = .systemFont16Medium
        monthlyLabel.textColor = .textPrimary

        monthlyPicker.dataSource = self
        monthlyPicker.delegate = self
        monthlyPicker.selectRow((storedSettings?.monthDay ?? 1) - 1, inComponent: 0, animated: false)
        monthlyPicker.heightAnchor.constraint(equalToConstant: pickerHeight).isActive = true
        monthlyPicker.overrideUserInterfaceStyle = .light

        monthlyStack.addArrangedSubview(monthlyLabel)
        monthlyStack.addArrangedSubview(monthlyPicker)
        stack.addArrangedSubview(monthlyStack)

        let saveButtonContainer = UIView()
        saveButton.backgroundColor = .clear
        saveButton.layer.borderWidth = .borderWidth2
        saveButton.layer.borderColor = UIColor.buttonsPrimary.cgColor
        saveButton.layer.cornerRadius = .cornerRadius16
        saveButton.layer.masksToBounds = true
        saveButton.clipsToBounds = true
        saveButton.setTitleColor(.buttonsPrimary, for: .normal)
        saveButton.setTitle(.Localized.reminderViewButtonSave, for: .normal)
        saveButton.titleLabel?.font = .systemFont16Medium
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButtonContainer.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: saveButtonContainer.centerXAnchor),
            saveButton.centerYAnchor.constraint(equalTo: saveButtonContainer.centerYAnchor),
            saveButton.topAnchor.constraint(equalTo: saveButtonContainer.topAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: .buttonsWidth240),
            saveButtonContainer.heightAnchor.constraint(equalToConstant: .buttonsHeight48)
        ])

        stack.addArrangedSubview(saveButtonContainer)
    }

    private func updateEnabledState() {
        let isOn = enableSwitch.isOn
        timePicker.isEnabled = isOn
        frequencySegmented.isEnabled = isOn
        weeklyPicker.isUserInteractionEnabled = isOn
        monthlyPicker.isUserInteractionEnabled = isOn
    }

    private func updateVisibility(for frequency: ReminderFrequency) {
        switch frequency {
        case .daily:
            monthlyStack.isHidden = true
            weeklyStack.isHidden = true
        case .weekly, .biweekly:
            monthlyStack.isHidden = true
            weeklyStack.isHidden = false
        case .monthly:
            monthlyStack.isHidden = false
            weeklyStack.isHidden = true
        }

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func frequencyChanged(_ sender: UISegmentedControl) {
        let frequency = ReminderFrequency(rawValue: sender.selectedSegmentIndex) ?? .daily
        updateVisibility(for: frequency)
    }

    @objc private func saveTapped() {
        let selectedRow = weeklyPicker.selectedRow(inComponent: 0)
        let selectedWeekday = weekDays.indices.contains(selectedRow)
            ? weekDays[selectedRow].weekday
            : storedSettings?.weekday ?? .sunday

        storedSettings = ReminderSettings(
            isEnabled: enableSwitch.isOn,
            frequency: ReminderFrequency(rawValue: frequencySegmented.selectedSegmentIndex) ?? .daily,
            time: timePicker.date,
            weekday: selectedWeekday,
            monthDay: Int(monthDays[monthlyPicker.selectedRow(inComponent: 0)]) ?? 1
        )

        guard let storedSettings else { return }

        dismiss(animated: true) { [weak self] in
            self?.onSave?(storedSettings)
        }
    }

    @objc private func switchChanged() {
        updateEnabledState()
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension ReminderSettingsVC: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == weeklyPicker {
            return weekDays.count
        } else if pickerView == monthlyPicker {
            return monthDays.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == weeklyPicker {
            return weekDays[row].title
        } else if pickerView == monthlyPicker {
            return monthDays[row]
        }
        return nil
    }
}
