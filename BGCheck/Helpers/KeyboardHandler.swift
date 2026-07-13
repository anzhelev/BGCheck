import UIKit

protocol KeyboardHandler: AnyObject {
    var keyboardWillShowAction: ((Notification) -> Void)? { get set }
    var keyboardWillHideAction: ((Notification) -> Void)? { get set }
    func setupKeyboardHandling()
    func removeKeyboardHandling()
}

extension KeyboardHandler where Self: UIViewController {
    func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main) { [weak self] notification in
                self?.keyboardWillShowAction?(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main) { [weak self] notification in
                self?.keyboardWillHideAction?(notification)
        }
    }
    
    func removeKeyboardHandling() {
        NotificationCenter.default.removeObserver(self)
    }
}
