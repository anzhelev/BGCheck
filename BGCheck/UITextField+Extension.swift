import UIKit

extension UITextField {
    
    func addLeftPadding(_ leftPadding: Int) {
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(leftPadding), height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
