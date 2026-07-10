import UIKit

// MARK: - Контроллер настроек
final class ReminderSettingsVC: UIViewController {

    // MARK: - UI элементы
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    private let enableSwitch = UISwitch()
    private let enableLabel = UILabel()

    private let timeRowStack = UIStackView()
    private let timeLabel = UILabel()
    private let timePicker = UIDatePicker()

    private let frequencyLabel = UILabel()
    private let frequencySegmented = UISegmentedControl(items: UIConstants.frequencyOptions)

    private let weeklyStack = UIStackView()
    private let weeklyLabel = UILabel()
    private let weeklyPicker = UIPickerView()

    private let monthlyStack = UIStackView()
    private let monthlyLabel = UILabel()
    private let monthlyPicker = UIPickerView()
    private let pickerHeight: CGFloat = UIConstants.buttonsWidthSecondary

    private let saveButton = UIButton(type: .system)

    // MARK: - Данные для пикеров
    private let weekDays = UIConstants.weekDays
    private let monthDays = Array(1...31).map { "\($0)" }
    
     var storedSettings: ReminderSettings?

    // MARK: - Замыкание для возврата настроек
    var onSave: ((ReminderSettings) -> Void)?
    
    init(storedSettings: ReminderSettings) {
        
        super.init(nibName: nil, bundle: nil)
        self.storedSettings = storedSettings
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupCardView()
        updateVisibility(for: frequencySegmented.selectedSegmentIndex)
        updateEnabledState()
    }

    // MARK: - Настройка карточки
    private func setupCardView() {
        let cardView = UIView()
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = UIConstants.reminderViewCornerRadius
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

    // MARK: - Содержимое (порядок: включение, время, частота, доп. настройки, сохранить)
    private func setupContent(in container: UIView) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = UIConstants.verticalUIOffsetTertiary
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: UIConstants.horizontalUIOffset),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: UIConstants.horizontalUIOffset),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -UIConstants.horizontalUIOffset),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -UIConstants.horizontalUIOffset)
        ])

        // ------ 1. Заголовок и крестик ------
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        headerStack.alignment = .center

        titleLabel.text = UIConstants.reminderViewTitle
        titleLabel.font = UIConstants.titleFontPrimary

        closeButton.setImage(UIImage(systemName: UIConstants.reminderViewCloseButtonTitle), for: .normal)
        closeButton.tintColor = .buttonsPrimary
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(closeButton)
        stack.addArrangedSubview(headerStack)

        // ------ 2. Включение/выключение ------
        let enableStack = UIStackView()
        enableStack.axis = .horizontal
        enableStack.spacing = UIConstants.buttonsSpacing
        enableStack.alignment = .center

        enableLabel.text = UIConstants.reminderViewLabelEnabled
        enableLabel.font = UIConstants.buttonsLabelFontPrimary

        enableSwitch.isOn = storedSettings?.isEnabled ?? false
        enableSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        enableStack.addArrangedSubview(enableLabel)
        enableStack.addArrangedSubview(UIView()) // распорка
        enableStack.addArrangedSubview(enableSwitch)
        stack.addArrangedSubview(enableStack)

        // ------ 3. Время (компактная строка) ------
        timeRowStack.axis = .horizontal
        timeRowStack.spacing = UIConstants.buttonsSpacing
        timeRowStack.alignment = .center
        timeRowStack.distribution = .fill

        timeLabel.text = UIConstants.reminderViewLabelTime
        timeLabel.font = UIConstants.buttonsLabelFontPrimary

        timePicker.preferredDatePickerStyle = .compact
        timePicker.datePickerMode = .time
        timePicker.locale = Locale(identifier: "en_US")
        timePicker.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        timePicker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timePicker.date = storedSettings?.time ?? Date()

        timeRowStack.addArrangedSubview(timeLabel)
        timeRowStack.addArrangedSubview(timePicker)
        stack.addArrangedSubview(timeRowStack)

        // ------ 4. Заголовок частоты ------
        frequencyLabel.text = "Repeat every:"
        frequencyLabel.font = UIConstants.buttonsLabelFontPrimary
        stack.addArrangedSubview(frequencyLabel)

        // ------ 5. Переключатель частоты ------
        frequencySegmented.selectedSegmentIndex = storedSettings?.frequency ?? 0
        frequencySegmented.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        stack.addArrangedSubview(frequencySegmented)

        // ------ 6. Еженедельные настройки (для Week и 2 Weeks) ------
        weeklyStack.axis = .vertical
        weeklyStack.spacing = UIConstants.verticalStackViewSpacing
        weeklyStack.isHidden = true

        weeklyLabel.text = UIConstants.reminderViewLabelDayOfWeek
        weeklyLabel.font = UIConstants.buttonsLabelFontPrimary

        weeklyPicker.dataSource = self
        weeklyPicker.delegate = self
        weeklyPicker.selectRow(storedSettings?.weekDayIndex ?? 0, inComponent: 0, animated: false)
        weeklyPicker.heightAnchor.constraint(equalToConstant: pickerHeight).isActive = true
        
        weeklyStack.addArrangedSubview(weeklyLabel)
        weeklyStack.addArrangedSubview(weeklyPicker)
        stack.addArrangedSubview(weeklyStack)

        // ------ 7. Ежемесячные настройки (только для Month) ------
        monthlyStack.axis = .vertical
        monthlyStack.spacing = UIConstants.verticalStackViewSpacing
        monthlyStack.isHidden = true

        monthlyLabel.text = UIConstants.reminderViewLabelDayOfMonth
        monthlyLabel.font = UIConstants.buttonsLabelFontPrimary

        monthlyPicker.dataSource = self
        monthlyPicker.delegate = self
        monthlyPicker.selectRow((storedSettings?.monthDay ?? 1) - 1, inComponent: 0, animated: false)
        monthlyPicker.heightAnchor.constraint(equalToConstant: pickerHeight).isActive = true


        monthlyStack.addArrangedSubview(monthlyLabel)
        monthlyStack.addArrangedSubview(monthlyPicker)
        stack.addArrangedSubview(monthlyStack)

        // ------ 8. Кнопка сохранения ------
        let saveButtonContainer = UIView()
        saveButton.backgroundColor = .clear
        saveButton.layer.borderWidth = UIConstants.buttonsBorderWidthPrimary
        saveButton.layer.borderColor = UIColor.buttonsPrimary.cgColor
        saveButton.layer.cornerRadius = UIConstants.buttonsCornerRadius
        saveButton.layer.masksToBounds = true
        saveButton.clipsToBounds = true
        saveButton.setTitleColor(.buttonsPrimary, for: .normal)
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIConstants.buttonsLabelFontPrimary
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButtonContainer.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: saveButtonContainer.centerXAnchor),
            saveButton.centerYAnchor.constraint(equalTo: saveButtonContainer.centerYAnchor),
            saveButton.topAnchor.constraint(equalTo: saveButtonContainer.topAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: UIConstants.buttonsWidthPrimary),
            saveButtonContainer.heightAnchor.constraint(equalToConstant: UIConstants.buttonsHeight)
        ])
        
        stack.addArrangedSubview(saveButtonContainer)
    }

    // MARK: - Логика видимости дополнительных настроек
    @objc private func frequencyChanged(_ sender: UISegmentedControl) {
        updateVisibility(for: sender.selectedSegmentIndex)
    }

    private func updateVisibility(for index: Int) {
        // Показываем день недели для Week (1) и 2 Weeks (2)
        weeklyStack.isHidden = index != 1 && index != 2
        // Показываем число месяца только для Month (3)
        monthlyStack.isHidden = index != 3

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    // Блокировка элементов при выключенном переключателе
    private func updateEnabledState() {
        let isOn = enableSwitch.isOn
        timePicker.isEnabled = isOn
        frequencySegmented.isEnabled = isOn
        weeklyPicker.isUserInteractionEnabled = isOn
        monthlyPicker.isUserInteractionEnabled = isOn
    }

    @objc private func switchChanged() {
        updateEnabledState()
    }

    // MARK: - Действия
    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        storedSettings = ReminderSettings(
            isEnabled: enableSwitch.isOn,
            frequency: frequencySegmented.selectedSegmentIndex,
            time: timePicker.date,
            weekDayIndex: weeklyPicker.selectedRow(inComponent: 0),
            monthDay: Int(monthDays[monthlyPicker.selectedRow(inComponent: 0)]) ?? 1
        )
        if let storedSettings {
            onSave?(storedSettings)
            dismiss(animated: true)
        }
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
            return weekDays[row]
        } else if pickerView == monthlyPicker {
            return monthDays[row]
        }
        return nil
    }
}
