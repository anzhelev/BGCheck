import UIKit

enum OnboardingVCBinding {
    case addItem(IndexPath)
    case removeItem([IndexPath])
    case doneButtonAction
    case updateRemindButtonState(Bool)
    case showHistory(Int, Case)
}
