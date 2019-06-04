//
//  IndicatorView.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 6/3/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
@IBDesignable class IndicatorView:UIView {
    struct Config {
        let primaryColor:UIColor
        let secondaryColor:UIColor
        let textColor:UIColor
        let cornerRadius:CGFloat
    }
    @IBInspectable var primaryColor:UIColor = .black
    @IBInspectable var secondaryColor:UIColor = .black
    
    
    @IBInspectable var cornerRadius:CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    var indicatorCenter:CGPoint?
    var isSelected = false
    var isEnabled = true
    
    
    override init(frame: CGRect) {
        let f = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            .insetBy(dx: 0, dy: -5)
            .offsetBy(dx: 0, dy: -5)
        
        
        super.init(frame: frame)
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
       

    }
    
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        //setup(isSelected: false)
        setNeedsDisplay()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        //setup(isSelected: false)
        
     
        setNeedsDisplay()
    }
   
    public func configure(with config:Config) {
        primaryColor = config.primaryColor
        secondaryColor = config.secondaryColor
        
        layer.cornerRadius = config.cornerRadius
        backgroundColor = .clear
        setNeedsDisplay()
        
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        var path = UIBezierPath(roundedRect: rect
            .insetBy(dx: 0, dy: 5)
            .offsetBy(dx: 0, dy: -5),
                                byRoundingCorners: .allCorners,
                                cornerRadii: CGSize(width: layer.cornerRadius, height: layer.cornerRadius))
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - 10, y: rect.maxY - 10))
        path.addLine(to: CGPoint(x: rect.midX + 10, y: rect.maxY - 10))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.close()
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
}
