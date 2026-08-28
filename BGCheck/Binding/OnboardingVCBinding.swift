import UIKit

enum OnboardingVCBinding {

    case addItem(IndexPath)
    case doneButtonAction
    case removeItem([IndexPath])
    case showHistory(Int, Case)
    case showNotificationPermissionDenied
    case updateRemindButtonState(Bool)
}
