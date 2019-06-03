//
//  ACButton.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 2/12/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//


import UIKit
import HMMarkup

@IBDesignable open class ACButton : HMMarkupButton {

    @IBInspectable var cornerRadius:CGFloat = 24.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    open override var isSelected: Bool{
        didSet {
            self.setNeedsDisplay()

        }
    }
    @IBInspectable var primaryColor:UIColor = UIColor(named: "Primary") ?? UIColor.white
    @IBInspectable var secondaryColor:UIColor = UIColor(named: "Primary Gradient") ?? UIColor.gray
    
    open override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: .allCorners,
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        path.addClip()
        let context = UIGraphicsGetCurrentContext()
        
        let colors = (!isSelected && isEnabled) ? [secondaryColor.cgColor,
                                                   primaryColor.cgColor] : [primaryColor.cgColor,
                                                                            primaryColor.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:bounds.height)
        context?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options:[])
    }
    override open func setup(isSelected:Bool){
        super.setup(isSelected:isSelected)
//        tintColor = .clear
        imageView?.layer.zPosition = 1
        
        if isEnabled {
            self.alpha = 1.0
        } else {
            self.alpha = 0.5
        }
        layer.cornerRadius = cornerRadius
        self.setNeedsDisplay()

      
        
    }
    
    open override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        

    }
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isSelected = true

    }
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isSelected = false


    }
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isSelected = false


    }
}

