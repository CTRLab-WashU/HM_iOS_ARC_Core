//
//  Buttons.swift
//  Arc
//
//  Created by Philip Hayes on 6/26/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation


public struct Drawing {
	public struct GradientButton {
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
