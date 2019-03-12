//
//  ACButton.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 2/12/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//


import UIKit

@IBDesignable open class ACButton : UIButton {
    
    @IBInspectable var cornerRadius:CGFloat = 24.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var primaryColor:UIColor = UIColor(named: "Primary") ?? UIColor.white
    @IBInspectable var secondaryColor:UIColor = UIColor(named: "Primary Gradient") ?? UIColor.gray
    var gradient:CAGradientLayer?
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup(isSelected: false)
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup(isSelected: false)
    }
    
    
//    override open var isHighlighted: Bool {
//        didSet {
//            setup(isSelected: isHighlighted)
//        }
//    }
//    override open var isEnabled: Bool {
//        didSet {
//            if !isEnabled {
//                setup(isSelected: false)
//
//            } else {
//                setup(isSelected: isHighlighted)
//
//            }
//        }
//    }
//    override open var intrinsicContentSize: CGSize {
//        return CGSize(width: 216, height: 48)
//    }
    override open func layoutIfNeeded() {
        super.layoutIfNeeded()
        
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        setup(isSelected: isHighlighted)
    }
    func setup(isSelected:Bool){
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        layer.cornerRadius = self.cornerRadius
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        layer.shadowOpacity =  1
        layer.shadowRadius = (!isSelected) ? 2 : 0
        let gradient = self.gradient ?? CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        gradient.colors = (!isSelected && isEnabled) ? [secondaryColor.cgColor,
                                                        primaryColor.cgColor] : [primaryColor.cgColor,
                                                                                 primaryColor.cgColor]
        
        if isEnabled {
            self.alpha = 1.0
        } else {
            self.alpha = 0.5
        }
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.cornerRadius = 24
        if gradient.superlayer == nil {
            self.gradient = gradient
            layer.addSublayer(gradient)
        }
        CATransaction.commit()
    }
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        setup(isSelected: true)

    }
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        setup(isSelected: false)

    }
}

