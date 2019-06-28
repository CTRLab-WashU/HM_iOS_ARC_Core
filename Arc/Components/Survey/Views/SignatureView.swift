//
//  SignatureView.swift
//  CRI
//
//  Created by Philip Hayes on 3/5/19.
//  Copyright © 2019 healthyMedium. All rights reserved.
//

import Foundation
import UIKit
public enum SignatureViewContentState {
    case empty, dirty
}
public protocol SignatureViewDelegate : class {
    func signatureViewContentChanged(state:SignatureViewContentState)
    
}
open class SignatureView: BorderedUIView, SurveyInput {
    public var parentScrollView: UIScrollView?
    
    public var didChangeValue: (() -> ())?
    
    public var isBottomAnchored: Bool = true
    
    public var orientation: UIStackView.Alignment = .bottom
    
    public var didFinishSetup: (() -> ())?
    
    public var tryNext: (() -> ())?
    
    
    public var path:UIBezierPath = UIBezierPath()
    public var state:SignatureViewContentState = .empty
    weak public var delegate:SignatureViewDelegate?
    
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        isExclusiveTouch = true
        didFinishSetup?()

    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override open func draw(_ rect: CGRect) {
        // Drawing code
        UIColor(named:"Primary")!.set()
        path.stroke()
    }

    public func getValue() -> QuestionResponse? {
        guard let data = save() else {
            return nil
        }
        return AnyResponse(type: .image, value: data)
    }
    
    public func setValue(_ value: QuestionResponse?) {
        
    }
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let location = touches.first?.location(in: self) else {
            return
        }
        parentScrollView?.isScrollEnabled = false
        path.move(to: location)
    }
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        parentScrollView?.isScrollEnabled = false

        path.addLine(to: location)
        self.setNeedsDisplay()
        
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        parentScrollView?.isScrollEnabled = true

        delegate?.signatureViewContentChanged(state: .dirty)
        state = .dirty
        didChangeValue?()
        
    }
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        parentScrollView?.isScrollEnabled = true

    }
    @IBAction func xPressed(sender:UIButton) {
        clear()
        
    }
    public func clear(){
        path = UIBezierPath()
        self.setNeedsDisplay()
        delegate?.signatureViewContentChanged(state: .empty)
        state = .empty
        didChangeValue?()
    }
    public func save() -> UIImage?{
        
        guard state != .empty else {
            return nil
        }
        UIGraphicsBeginImageContext(self.frame.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        
        return img
    }
	
	public func supplementaryViews(for view: UIView) {
		view.acButton {
			$0.setTitle("Undo", for: .normal)
		}
	}
    
}


extension UIView {
	
	@discardableResult
	public func signatureInput(apply closure: (SignatureView) -> Void) -> SignatureView {
		custom(SignatureView.get(), apply: closure)
	}
	
}
