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
        public let primaryColor:UIColor
        public let secondaryColor:UIColor
        public let textColor:UIColor
        public let cornerRadius:CGFloat
		public let arrowEnabled:Bool
        public let arrowAbove:Bool
		
        public init(primaryColor:UIColor, secondaryColor:UIColor,textColor:UIColor,cornerRadius:CGFloat,arrowEnabled:Bool,arrowAbove:Bool) {
			self.primaryColor = primaryColor
			self.secondaryColor = secondaryColor
			self.textColor = textColor
			self.cornerRadius = cornerRadius
			self.arrowEnabled = arrowEnabled
            self.arrowAbove = arrowAbove
		}
    }
    @IBInspectable public var primaryColor:UIColor = .black
    @IBInspectable public var secondaryColor:UIColor = .black
    
    
    @IBInspectable public var cornerRadius:CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    var indicatorCenter:CGPoint?
    var isSelected = false
    var isEnabled = true
    var isArrowEnabled = true
    var isArrowAbove = false
	var container:UIStackView?
	var path:UIBezierPath?
    override public init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        
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
        isArrowAbove = config.arrowAbove
        layer.cornerRadius = config.cornerRadius
        backgroundColor = .clear
        setNeedsDisplay()
        
    }
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        var insetRect = rect
        
        // below
        if isArrowEnabled && !isArrowAbove {
            insetRect = rect
                .insetBy(dx: 0, dy: 5)
                .offsetBy(dx: 0, dy: -5)
        }
		
        // above
        if isArrowEnabled && isArrowAbove {
            insetRect = rect
                .insetBy(dx: 0, dy: 5)
                .offsetBy(dx: 0, dy: 5)
        }
        
		path = UIBezierPath(roundedRect:insetRect,
                                byRoundingCorners: .allCorners,
                                cornerRadii: CGSize(width: layer.cornerRadius, height: layer.cornerRadius))
		
        // below
        if isArrowEnabled && !isArrowAbove {
            path?.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path?.addLine(to: CGPoint(x: rect.midX - 10, y: rect.maxY - 10))
            path?.addLine(to: CGPoint(x: rect.midX + 10, y: rect.maxY - 10))
            path?.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path?.close()
        }
		

        // above
        if isArrowEnabled && isArrowAbove {
            path?.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path?.addLine(to: CGPoint(x: rect.midX - 10, y: rect.minY + 10))
            path?.addLine(to: CGPoint(x: rect.midX + 10, y: rect.minY + 10))
            path?.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
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
