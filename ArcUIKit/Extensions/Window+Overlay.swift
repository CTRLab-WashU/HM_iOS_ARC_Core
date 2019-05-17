import UIKit
public enum OverlayShape {
    case rect(UIView), roundedRect(UIView, CGFloat), circle(UIView)
    
    public func path(forView parent:UIView) -> UIBezierPath {
        switch self {
        case .rect(let view):
            return UIBezierPath.init(rect: parent.convert(view.frame, from: parent))
            
        case .circle(let view):
            let rect = parent.convert(view.frame, from: parent)
            return UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: max(rect.width/2, rect.height/2) , startAngle: CGFloat.pi , endAngle: CGFloat.pi + CGFloat.pi * 2, clockwise: true)
            
            
        case .roundedRect(let view, let cornerRadius):
            let rect = parent.convert(view.frame, from: parent)
            
            return UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            
        }
    }
}
fileprivate class OverlayView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
public extension UIWindow {
    static var overlayId:Int {
        get {
            return 95384754
        }
    }
    func overlayView(view:UIView, withShapes shapes:[OverlayShape]) {
        if let oldView = self.viewWithTag(UIWindow.overlayId) as? OverlayView {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                oldView.alpha = 0
                
            }, completion: { (stop) in
                oldView.removeFromSuperview()
            })
        }
        
        
        let overlay = OverlayView(frame: self.bounds)
        overlay.tag = UIWindow.overlayId
        overlay.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        overlay.alpha = 0
        self.addSubview(overlay)
        
        let path = UIBezierPath()
        path.append(UIBezierPath.init(rect: self.bounds))
        
        for v in shapes {
            
            path.append(v.path(forView: self))
            
            
        }
        
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.frame = self.bounds
        maskLayer.fillRule = .evenOdd
        overlay.layer.mask = maskLayer
        
        
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveLinear, animations: {
            overlay.alpha = 1
            
        }, completion: { (stop) in
            
        })
    }
    
}
