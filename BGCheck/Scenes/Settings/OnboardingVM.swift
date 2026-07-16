import Foundation

class OnboardingVM {

    // MARK: - Public Properties
    var casesCount: Int {
        return cases.count
    }
    var onboardingVCBinding: Observable<OnboardingVCBinding> = Observable(nil)

    // MARK: - Private Properties
    private lazy var cases: [Case] = {
        loadCases()
    }()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private lazy var storedNotificationSettings: ReminderSettings = {
        loadNotificationSettings()
    }() {
        didSet {
            onboardingVCBinding.value = .updateRemindButtonState(storedNotificationSettings.isEnabled)
        }
    }
    private lazy var weekDays: [String] = {
        let calendar = Calendar.current
        return calendar.weekdaySymbols
    }()

    // MARK: - Public Methods
    func addCase() {
        cases.append(
            .init(
                caseName: nil,
                caseNumber: nil,
                pin: nil,
                history: nil
            )
        )
        onboardingVCBinding.value = .addItem(.init(row: casesCount - 1, section: 0))
    }

    func confirmButtonPressed() {
        saveCases()
        onboardingVCBinding.value = .doneButtonAction
    }

    func getAddButtonState() -> Bool {
        cases.count < 5
    }

    func getCellParams(for row: Int) -> OnboardingTableCellParams {
        .init(
            row: row,
            caseName: cases[row].caseName,
            caseNumber: cases[row].caseNumber,
            pin: cases[row].pin
        )
    }

    func getRemindState() -> Bool {
        storedNotificationSettings.isEnabled
    }

    func getStoredNotificationSettings() -> ReminderSettings {
        storedNotificationSettings
    }

    func getWeekDays() -> [String] {
        weekDays
    }

    func updateNotificationSettings(with newSettings: ReminderSettings) {
        storedNotificationSettings = newSettings
        if let encoded = try? encoder.encode(newSettings) {
            UserDefaults.standard.set(encoded, forKey: "notificationSettings")
        }
        updateReminders(with: newSettings)
    }

    // MARK: - Private Methods
    private func loadCases() -> [Case] {
        var cases: [Case] = []
        for row in 0...4 {
            let caseName = UserDefaults.standard.string(forKey: "case\(row)Name")
            let caseNumber = UserDefaults.standard.string(forKey: "case\(row)Number")
            let pin = UserDefaults.standard.string(forKey: "case\(row)Pin")
            var history: [HistoryRecord]?
            if let savedData = UserDefaults.standard.data(forKey: "case\(row)History"),
               let records = try? decoder.decode([HistoryRecord].self, from: savedData) {
                history = records
            }
            if caseName != nil || caseNumber != nil || pin != nil {
                cases.append(
                    .init(
                        caseName: caseName,
                        caseNumber: caseNumber,
                        pin: pin,
                        history: history
                    )
                )
            }
        }
        return cases
    }

    private func loadNotificationSettings() -> ReminderSettings {
        if let savedData = UserDefaults.standard.data(forKey: "notificationSettings"),
           let settings = try? decoder.decode(ReminderSettings.self, from: savedData) {
            return settings
        } else {
            return .init(
                isEnabled: false,
                frequency: 1,
                time: Calendar.current.startOfDay(for: Date()) + 39600,
                weekDayIndex: 0,
                monthDay: 1
            )
        }
    }

    private func saveCases() {
        updateHistory()
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix("case") {
            UserDefaults.standard.removeObject(forKey: key)
        }

        var storedCases = false

        for (index, caseData) in cases.enumerated() {
            if caseData.caseName?.isEmpty == false {
                UserDefaults.standard.set(caseData.caseName, forKey: "case\(index)Name")
                storedCases = true
            }
            if caseData.caseNumber?.isEmpty == false {
                UserDefaults.standard.set(caseData.caseNumber, forKey: "case\(index)Number")
                storedCases = true
            }
            if caseData.pin?.isEmpty == false {
                UserDefaults.standard.set(caseData.pin, forKey: "case\(index)Pin")
                storedCases = true
            }
            if let encoded = try? encoder.encode(caseData.history) {
                UserDefaults.standard.set(encoded, forKey: "case\(index)History")
            }
        }
        UserDefaults.standard.set(storedCases, forKey: "storedCases")
    }

    private func updateHistory() {
        for index in cases.indices {
            if UserDefaults.standard.object(forKey: "case\(index)History") != nil {
                if let savedData = UserDefaults.standard.data(forKey: "case\(index)History"),
                   let records = try? decoder.decode([HistoryRecord].self, from: savedData) {
                    cases[index] = .init(
                        caseName: cases[index].caseName,
                        caseNumber: cases[index].caseNumber,
                        pin: cases[index].pin,
                        history: records
                    )
                }
            } else {
                cases[index] = .init(
                    caseName: cases[index].caseName,
                    caseNumber: cases[index].caseNumber,
                    pin: cases[index].pin,
                    history: [.init(date: Date(), record: .Localized.historyVCMessageStartMonitoring)]
                )
            }
        }
    }

    private func updateReminders(with newSettings: ReminderSettings) {
        if newSettings.isEnabled {
            ReminderManager.shared.createReminder(
                title: .Localized.appName,
                targetTime: newSettings.time,
                frequency: .init(rawValue: newSettings.frequency) ?? .monthly,
                weekday: newSettings.weekDayIndex + 1,
                monthDay: newSettings.monthDay,
                notes: .Localized.reminderMessage
            ) { success, error in
                if success {
                    print("@@@ Reminder created")
                } else {
                    print("@@@ Error creating reminder: \(String(describing: error))")
                }
            }
        } else {
            ReminderManager.shared.removeReminders(withTitle: .Localized.appName) { success, error in
                if success {
                    print("@@@ Reminders disabled")
                } else {
                    print("@@@ Error disabling reminders: \(String(describing: error))")
                }
            }
        }
    }
}

// MARK: - OnboardingTableCellDelegate
extension OnboardingVM: OnboardingTableCellDelegate {

    func caseNameChanged(to newName: String, for row: Int) {
        cases[row] = .init(
            caseName: newName,
            caseNumber: cases[row].caseNumber,
            pin: cases[row].pin,
            history: cases[row].history
        )
        saveCases()
    }

    func caseNumberChanged(to newName: String, for row: Int) {
        cases[row] = .init(
            caseName: cases[row].caseName,
            caseNumber: newName,
            pin: cases[row].pin,
            history: cases[row].history
        )
        saveCases()
    }

    func deleteButtonTapped(for row: Int) {
        cases.remove(at: row)
        onboardingVCBinding.value = .removeItem([.init(row: row, section: 0)])
        saveCases()
    }

    func historyButtonTapped(for row: Int) {
        saveCases()
        onboardingVCBinding.value = .showHistory(row, cases[row])
    }

    func pinChanged(to newPin: String, for row: Int) {
        cases[row] = .init(
            caseName: cases[row].caseName,
            caseNumber: cases[row].caseNumber,
            pin: newPin,
            history: cases[row].history
        )
        saveCases()
    }
}
