import UIKit
import WebKit

protocol ClickTrackingWebViewDelegate: AnyObject {
    func clickTracked(on point: CGPoint)
}

class ClickTrackingWebView: WKWebView {
    weak var delegate: ClickTrackingWebViewDelegate?
    
    private var clickPoint: CGPoint = .zero
    
    init(frame: CGRect, configuration: WKWebViewConfiguration, delegate: ClickTrackingWebViewDelegate?) {
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if clickPoint != point {
            clickPoint = point
            delegate?.clickTracked(on: point)
        }
        return hitView
    }
}
