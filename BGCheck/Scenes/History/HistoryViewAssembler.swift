import UIKit

final class HistoryViewAssembler {
    
    private let number: Int
    private let userCase: Case
    
    init(number: Int, userCase: Case) {
        self.number = number
        self.userCase = userCase
    }
    
    public func build() -> UIViewController {
        let viewModel = HistoryVM(number: number, userCase: userCase)
        let viewController = HistoryVC(viewModel: viewModel)
        return viewController
    }
}
