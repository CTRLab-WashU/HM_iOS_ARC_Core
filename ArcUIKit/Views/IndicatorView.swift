//
//  IndicatorView.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 6/3/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit


@IBDesignable public class IndicatorView:UIView {
    public struct Config {
        let primaryColor:UIColor
        let secondaryColor:UIColor
        let textColor:UIColor
        let cornerRadius:CGFloat
		let arrowEnabled:Bool
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
    var isArrowEnabled = true
	var container:UIStackView?
	var path:UIBezierPath?
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
       

    }
	override func add(_ view: UIView) {
		if container == nil {
			let s = UIStackView()
			self.addSubview(s)
			s.frame = self.bounds
			s.alignment = .fill
			s.axis = .vertical
			s.spacing = 8
			let v = self
			s.layout {

				$0.top == v.topAnchor
				$0.trailing == v.trailingAnchor
				$0.bottom == v.bottomAnchor
				$0.leading == v.leadingAnchor

			}
			
			
			container = s
		}
		container?.addArrangedSubview(view)
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
        isArrowEnabled = config.arrowEnabled
        layer.cornerRadius = config.cornerRadius
        backgroundColor = .clear
        setNeedsDisplay()
        
    }
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        var insetRect = rect
		if isArrowEnabled {
			insetRect = rect
				.insetBy(dx: 0, dy: 5)
				.offsetBy(dx: 0, dy: -5)
		}
		
		path = UIBezierPath(roundedRect:insetRect,
                                byRoundingCorners: .allCorners,
                                cornerRadii: CGSize(width: layer.cornerRadius, height: layer.cornerRadius))
		
		if isArrowEnabled {
			path?.move(to: CGPoint(x: rect.midX, y: rect.maxY))
			path?.addLine(to: CGPoint(x: rect.midX - 10, y: rect.maxY - 10))
			path?.addLine(to: CGPoint(x: rect.midX + 10, y: rect.maxY - 10))
			path?.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
			path?.close()
		}
		
		
        let context = UIGraphicsGetCurrentContext()
		
		path?.addClip()

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
