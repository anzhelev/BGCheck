import Foundation

class OnboardingViewModel {
    
    // MARK: - Public Properties
    var onboardingVCBinding: Observable<OnboardingVCBinding> = Observable(nil)
    var casesCount: Int {
        return cases.count
    }
    
    // MARK: - Private Properties
    private lazy var cases: [Case] = {
        return loadCases()
    }()
    
    // MARK: - Public Methods
    func addCase() {
        cases.append(.init(caseNumber: nil, pin: nil))
        onboardingVCBinding.value = .addItem(.init(row: casesCount - 1, section: 0))
    }
    
    func confirmButtonPressed() {
        saveCases()
        onboardingVCBinding.value = .doneButtonAction
    }
    
    func getAddButtonState() -> Bool {
        cases.count < 5
    }
    
    func getCellParams(for row: Int) -> MainTableCellParams {
        .init(row: row,
              caseNumber: cases[row].caseNumber,
              pin: cases[row].pin,
              separator: row != cases.count - 1
        )
    }
    
    private func loadCases() -> [Case] {
        var cases: [Case] = []
        var caseName: String?
        var pin: String?
        for caseNumber in 0...4 {
            caseName = UserDefaults.standard.string(forKey: "case\(caseNumber)Number")
            pin = UserDefaults.standard.string(forKey: "case\(caseNumber)Pin")
            if caseName != nil || pin != nil {
                cases.append(.init(caseNumber: caseName, pin: pin))
            }
        }
        
        if cases.count == 0 {
            cases.append(.init(caseNumber: "12304/2021", pin: "527155"))
            cases.append(.init(caseNumber: "12781/2021", pin: "166511"))
            cases.append(.init(caseNumber: "12782/2021", pin: "076332"))
//            saveCases()
        }
        
        return cases
    }
    
    private func saveCases() {
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        
        var storedCases: Bool = false
        
        for (index, caseData) in cases.enumerated() {
            if caseData.caseNumber?.isEmpty == false {
                UserDefaults.standard.set(caseData.caseNumber, forKey: "case\(index)Number")
                storedCases = true
            }
            if caseData.pin?.isEmpty == false {
                UserDefaults.standard.set(caseData.pin, forKey: "case\(index)Pin")
                storedCases = true
            }
        }
        UserDefaults.standard.set(storedCases ? true : false, forKey: "storedCases")
    }
}

// MARK: - MainTableCellDelegate
extension OnboardingViewModel: MainTableCellDelegate {
    func caseNumberChanged(to newName: String, for row: Int) {
        cases[row] = .init(caseNumber: newName, pin: cases[row].pin)
        saveCases()
    }
    
    func pinChanged(to newAge: String, for row: Int) {
        cases[row] = .init(caseNumber: cases[row].caseNumber, pin: newAge)
        saveCases()
    }
    
    func deleteButtonTapped(for row: Int) {
        cases.remove(at: row)
        onboardingVCBinding.value = .removeItem([.init(row: row, section: 0)])
        saveCases()
    }
}
