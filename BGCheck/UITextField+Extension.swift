import UIKit

extension UITextField {
    
    func addPadding(left: Int, right: Int) {
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(left), height: self.frame.height))
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(right), height: self.frame.height))
        self.leftView = leftPaddingView
        self.leftViewMode = ViewMode.always
        self.rightView = rightPaddingView
        self.rightViewMode = ViewMode.always
    }
}
