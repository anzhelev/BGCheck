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
        cases.append(.init(caseName: nil, caseNumber: nil, pin: nil))
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
              caseName: cases[row].caseName,
              caseNumber: cases[row].caseNumber,
              pin: cases[row].pin
//              separator: row != cases.count - 1
        )
    }
    
    private func loadCases() -> [Case] {
        var cases: [Case] = []
        var caseName: String?
        var caseNumber: String?
        var pin: String?
        for row in 0...4 {
            caseName = UserDefaults.standard.string(forKey: "case\(row)Name")
            caseNumber = UserDefaults.standard.string(forKey: "case\(row)Number")
            pin = UserDefaults.standard.string(forKey: "case\(row)Pin")
            if caseName != nil || caseNumber != nil || pin != nil {
                cases.append(.init(caseName: caseName, caseNumber: caseNumber, pin: pin))
            }
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
        }
        UserDefaults.standard.set(storedCases ? true : false, forKey: "storedCases")
    }
}

// MARK: - MainTableCellDelegate
extension OnboardingViewModel: MainTableCellDelegate {
    func caseNameChanged(to newName: String, for row: Int) {
        cases[row] = .init(caseName: newName, caseNumber: cases[row].caseNumber, pin: cases[row].pin)
        saveCases()
    }
    
    func caseNumberChanged(to newName: String, for row: Int) {
        cases[row] = .init(caseName: cases[row].caseName, caseNumber: newName, pin: cases[row].pin)
        saveCases()
    }
    
    func pinChanged(to newPin: String, for row: Int) {
        cases[row] = .init(caseName: cases[row].caseName, caseNumber: cases[row].caseNumber, pin: newPin)
        saveCases()
    }
    
    func deleteButtonTapped(for row: Int) {
        cases.remove(at: row)
        onboardingVCBinding.value = .removeItem([.init(row: row, section: 0)])
        saveCases()
    }
}
