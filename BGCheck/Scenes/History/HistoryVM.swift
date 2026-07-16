import Foundation

class HistoryVM {

    // MARK: - Public Properties
    var historyVCBinding: Observable<HistoryVCBinding> = Observable(nil)

    // MARK: - Private Properties
    private let encoder = JSONEncoder()
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = .Localized.historyVCDateFormat
        return formatter
    }()
    private var number: Int
    private var userCase: Case

    // MARK: - Initializers
    init(number: Int, userCase: Case) {
        self.number = number
        self.userCase = userCase
    }

    // MARK: - Public Methods
    func deleteButtonTapped(for row: Int) {
        var newHistory = userCase.history ?? []
        newHistory.remove(at: row)
        userCase = .init(
            caseName: userCase.caseName,
            caseNumber: userCase.caseNumber,
            pin: userCase.pin,
            history: newHistory
        )
        historyVCBinding.value = .removeItem([.init(row: row, section: 0)])

        if UserDefaults.standard.object(forKey: "case\(number)History") != nil {
            if let encoded = try? encoder.encode(userCase.history) {
                UserDefaults.standard.set(encoded, forKey: "case\(number)History")
            }
        }
    }

    func getCaseName() -> String {
        userCase.caseName?.isEmpty ?? true
        ? "\(String.Localized.webViewVCLabelCase) \(number + 1)"
        : userCase.caseName ?? ""
    }

    func getEntryDate(at index: Int) -> String {
        formatter.string(from: userCase.history?[index].date ?? Date())
    }

    func getEntryRecord(at index: Int) -> String {
        userCase.history?[index].record ?? ""
    }

    func getHistoryCount() -> Int {
        userCase.history?.count ?? 0
    }
}
