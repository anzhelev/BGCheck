import Foundation
//import EventKit
import UserNotifications

class OnboardingViewModel {

    // MARK: - Public Properties
    var onboardingVCBinding: Observable<OnboardingVCBinding> = Observable(nil)
    var casesCount: Int {
        return cases.count
    }

    // MARK: - Private Properties
//    private let eventStore = EKEventStore()
    private lazy var cases: [Case] = {
        loadCases()
    }()

    private lazy var storedNotificationSettings: ReminderSettings =
        loadNotificationSettings()
    {
        didSet {
            onboardingVCBinding.value = .updateRemindButtonState(
                storedNotificationSettings.isEnabled
            )
        }
    }
    
    private lazy var weekDays: [String] = {
        let calendar = Calendar.current
        return calendar.weekdaySymbols
    }()

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

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
        onboardingVCBinding.value = .addItem(
            .init(row: casesCount - 1, section: 0)
        )
    }

    func confirmButtonPressed() {
        saveCases()
        onboardingVCBinding.value = .doneButtonAction
    }

    func getAddButtonState() -> Bool {
        cases.count < 5
    }

    func getRemindState() -> Bool {
        storedNotificationSettings.isEnabled
    }

    func getStoredNotificationSettings() -> ReminderSettings {
        storedNotificationSettings
    }

    func updateNotificationSettings(with newSettings: ReminderSettings) {
        storedNotificationSettings = newSettings
        if let encoded = try? encoder.encode(newSettings) {
            UserDefaults.standard.set(encoded, forKey: "notificationSettings")
        }
        updateReminders(with: newSettings)
    }

    func getCellParams(for row: Int) -> OnboardingTableCellParams {
        .init(
            row: row,
            caseName: cases[row].caseName,
            caseNumber: cases[row].caseNumber,
            pin: cases[row].pin
        )
    }

    func getWeekDays() -> [String] {
        weekDays
    }
    
    private func updateReminders(with newSettings: ReminderSettings) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("@@@ Разрешение получено")
            } else {
                print("@@@ Разрешение не получено")
                return
            }
        }
        
        switch newSettings.isEnabled {
        case true:
            let content = UNMutableNotificationContent()
            content.title = UIConstants.reminderAppName
            content.body = UIConstants.reminderNotificationText
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = Calendar.current.component(.hour, from: newSettings.time)
            dateComponents.minute = Calendar.current.component(.minute, from: newSettings.time)
            
            switch newSettings.frequency {
            case 1:
                dateComponents.weekday = newSettings.weekDayIndex + 1
            case 2:
                dateComponents.day = newSettings.monthDay
            default:
                break
            }
   
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = UIConstants.notificationsID
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            center.add(request) { error in
                        if let error = error {
                            print("@@@ Ошибка при добавлении уведомления: \(error.localizedDescription)")
                        } else {
                            print("@@@ Уведомление успешно запланировано")
                        }
                    }
        case false:
            center.removePendingNotificationRequests(withIdentifiers: [UIConstants.notificationsID])
            print("@@@ Уведомления отключены")
        }
    }
    
    private func loadCases() -> [Case] {
        var cases: [Case] = []
        var caseName: String?
        var caseNumber: String?
        var pin: String?
        var history: [HistoryRecord]?
        for row in 0...4 {
            caseName = UserDefaults.standard.string(forKey: "case\(row)Name")
            caseNumber = UserDefaults.standard.string(
                forKey: "case\(row)Number"
            )
            pin = UserDefaults.standard.string(forKey: "case\(row)Pin")
            if let savedData = UserDefaults.standard.data(
                forKey: "case\(row)History"
            ),
                let records = try? decoder.decode(
                    [HistoryRecord].self,
                    from: savedData
                )
            {
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
        if let savedData = UserDefaults.standard.data(
            forKey: "notificationSettings"
        ),
            let settings = try? decoder.decode(
                ReminderSettings.self,
                from: savedData
            )
        {
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

    private func updateHistory() {
        for index in cases.indices {
            if UserDefaults.standard.object(forKey: "case\(index)History")
                != nil
            {
                if let savedData = UserDefaults.standard.data(
                    forKey: "case\(index)History"
                ),
                    let records = try? decoder.decode(
                        [HistoryRecord].self,
                        from: savedData
                    )
                {
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
                    history: [.init(date: Date(), record: UIConstants.caseInitialStatusLabelText)]
                )
            }
        }
    }

    private func saveCases() {
        updateHistory()
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix("case") {
            UserDefaults.standard.removeObject(forKey: key)
        }

        var storedCases: Bool = false

        for (index, caseData) in cases.enumerated() {
            if caseData.caseName?.isEmpty == false {
                UserDefaults.standard.set(
                    caseData.caseName,
                    forKey: "case\(index)Name"
                )
                storedCases = true
            }
            if caseData.caseNumber?.isEmpty == false {
                UserDefaults.standard.set(
                    caseData.caseNumber,
                    forKey: "case\(index)Number"
                )
                storedCases = true
            }
            if caseData.pin?.isEmpty == false {
                UserDefaults.standard.set(
                    caseData.pin,
                    forKey: "case\(index)Pin"
                )
                storedCases = true
            }
            if let encoded = try? encoder.encode(caseData.history) {
                UserDefaults.standard.set(
                    encoded,
                    forKey: "case\(index)History"
                )
            }
        }
        UserDefaults.standard.set(
            storedCases ? true : false,
            forKey: "storedCases"
        )
    }
}

// MARK: - MainTableCellDelegate
extension OnboardingViewModel: OnboardingTableCellDelegate {
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

    func pinChanged(to newPin: String, for row: Int) {
        cases[row] = .init(
            caseName: cases[row].caseName,
            caseNumber: cases[row].caseNumber,
            pin: newPin,
            history: cases[row].history
        )
        saveCases()
    }

    func historyButtonTapped(for row: Int) {
        saveCases()
        onboardingVCBinding.value = .showHistory(row, cases[row])
    }

    func deleteButtonTapped(for row: Int) {
        cases.remove(at: row)
        onboardingVCBinding.value = .removeItem([.init(row: row, section: 0)])
        saveCases()
    }
}
