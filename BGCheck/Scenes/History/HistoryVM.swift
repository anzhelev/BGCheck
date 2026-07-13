//
//  HistoryVM.swift
//  BGCheck
//
//  Created by Andrey Zhelev on 04.07.2026.
//

import Foundation

class HistoryVM {
    
    // MARK: - Public Properties
    var historyVCBinding: Observable<HistoryVCBinding> = Observable(nil)
    
    // MARK: - Private Properties
    private var number: Int
    private var userCase: Case
    private let encoder = JSONEncoder()
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
//        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    init(number: Int, userCase: Case) {
        self.number = number
        self.userCase = userCase
//        loadHistory()
    }
    
    // MARK: - Public Methods
    func getCaseName() -> String {
        userCase.caseName ?? ""
    }
    
    func getHistoryCount() -> Int {
        userCase.history?.count ?? 0
    }
    
    func getEntryDate(at index: Int) -> String {
        formatter.string(from: userCase.history?[index].date ?? Date())
    }
    
    func getEntryRecord(at index: Int) -> String {
        userCase.history?[index].record ?? ""
    }
    
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
}
