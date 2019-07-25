//
//  Buttons.swift
//  Arc
//
//  Created by Philip Hayes on 6/26/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation

public protocol ACDrawable{
	func draw()
}
public struct Drawing {
	public struct CircularBar : ACDrawable {
		var radius:CGFloat
		var strokeWidth:CGFloat
		
		public func draw() {
			
		}
		
		
	}
	
	public struct HorizontalBar : ACDrawable {
		public var rect:CGRect
		public var bounds:CGRect
		public var cornerRadius:CGFloat
		public var primaryColor:UIColor?
		public var progress:CGFloat
		
		
		public func draw() {
			
			let visible = CGRect(x: rect.origin.x, y: rect.origin.y, width: bounds.width * progress, height: bounds.height)
			let path = UIBezierPath(roundedRect: visible,
									byRoundingCorners: .allCorners,
									cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
			path.addClip()
			let context = UIGraphicsGetCurrentContext()
			context?.setFillColor((primaryColor ?? .black).cgColor)
			path.fill()
		}
	}
	
	public struct GradientButton : ACDrawable {
		var rect:CGRect
		var bounds:CGRect
		var cornerRadius:CGFloat
		var primaryColor:UIColor
		var secondaryColor:UIColor
		var isSelected:Bool
		var isEnabled:Bool
		
	
		public func draw() {
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
	}
}
