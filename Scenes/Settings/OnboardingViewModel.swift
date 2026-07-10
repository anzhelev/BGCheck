import Foundation

class OnboardingViewModel {
    
    // MARK: - Public Properties
    var onboardingVCBinding: Observable<OnboardingVCBinding> = Observable(nil)
    var casesCount: Int {
        return cases.count
    }
    
    // MARK: - Private Properties
    private lazy var cases: [Case] = {
        loadCases()
    }()
    
    private lazy var storedNotificationSettings: ReminderSettings = loadNotificationSettings() {
        didSet {
            onboardingVCBinding.value = .updateRemindButtonState(storedNotificationSettings.isEnabled)
        }
    }
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // MARK: - Public Methods
    func addCase() {
        cases.append(.init(caseName: nil,
                           caseNumber: nil, pin: nil,
                           history: [.init(date: Date(), record: UIConstants.caseInitialStatusLabelText)]
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
    }
    
    func getCellParams(for row: Int) -> OnboardingTableCellParams {
        .init(row: row,
              caseName: cases[row].caseName,
              caseNumber: cases[row].caseNumber,
              pin: cases[row].pin
        )
    }
    
    private func loadCases() -> [Case] {
        var cases: [Case] = []
        var caseName: String?
        var caseNumber: String?
        var pin: String?
        var history: [HistoryRecord]?
        for row in 0...4 {
            caseName = UserDefaults.standard.string(forKey: "case\(row)Name")
            caseNumber = UserDefaults.standard.string(forKey: "case\(row)Number")
            pin = UserDefaults.standard.string(forKey: "case\(row)Pin")
            if let savedData = UserDefaults.standard.data(forKey: "case\(row)History"),
               let records = try? decoder.decode([HistoryRecord].self, from: savedData) {
                history = records
            }
                
            if caseName != nil || caseNumber != nil || pin != nil {
                cases.append(.init(caseName: caseName, caseNumber: caseNumber, pin: pin, history: history))
            }
        }
        
        return cases
    }
    
    private func loadNotificationSettings() -> ReminderSettings {
        if let savedData = UserDefaults.standard.data(forKey: "notificationSettings"),
           let settings = try? decoder.decode(ReminderSettings.self, from: savedData) {
            return settings
        } else {
            return .init(isEnabled: false,
                         frequency: 1,
                         time: Calendar.current.startOfDay(for: Date()) + 39600,
                         weekDayIndex: 0,
                         monthDay: 1
            )
        }
    }
    
    private func saveCases() {
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix("case") {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        var storedCases: Bool = false
                    
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
        UserDefaults.standard.set(storedCases ? true : false, forKey: "storedCases")
    }
}

// MARK: - MainTableCellDelegate
extension OnboardingViewModel: OnboardingTableCellDelegate {
    func caseNameChanged(to newName: String, for row: Int) {
        cases[row] = .init(caseName: newName, caseNumber: cases[row].caseNumber, pin: cases[row].pin, history: cases[row].history)
        saveCases()
    }
    
    func caseNumberChanged(to newName: String, for row: Int) {
        cases[row] = .init(caseName: cases[row].caseName, caseNumber: newName, pin: cases[row].pin, history: cases[row].history)
        saveCases()
    }
    
    func pinChanged(to newPin: String, for row: Int) {
        cases[row] = .init(caseName: cases[row].caseName, caseNumber: cases[row].caseNumber, pin: newPin, history: cases[row].history)
        saveCases()
    }
    
    func historyButtonTapped(for row: Int) {
        onboardingVCBinding.value = .showHistory(row, cases[row])
    }
    
    func deleteButtonTapped(for row: Int) {
        cases.remove(at: row)
        onboardingVCBinding.value = .removeItem([.init(row: row, section: 0)])
        saveCases()
    }
}
