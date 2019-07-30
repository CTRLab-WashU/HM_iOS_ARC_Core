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
	
	public struct CheckMark : ACDrawable {
		var originPoint:CGPoint = .zero
		var keyFrames:[CGPoint] = []
		var path:UIBezierPath = UIBezierPath()
		var center:CGPoint = .zero
		var offset:CGPoint = .zero
		var progress:CGFloat = 0
		
		init() {
			path.lineWidth = 14.0
			
			keyFrames = [CGPoint(x: -20, y: -20),
						 CGPoint(x: 0, y: 0),
						 CGPoint(x: 40, y: -40)]
		}
		public func draw() {
			let context = UIGraphicsGetCurrentContext()
			path.removeAllPoints()
			var start = CGPoint(x: originPoint.x + keyFrames[0].x,
								y: originPoint.y + keyFrames[0].y)
			var end = CGPoint(x: originPoint.x + keyFrames[1].x,
							  y: originPoint.y + keyFrames[1].y)
			path.move(to: start)
			
			if progress < 0.5 {
				
				let keyProgress = CGFloat(Math.clamp(Double(progress * 2.0)))
				path.addLine(to: Math.lerp(a: start, b: end, t: keyProgress))
			} else {
				path.addLine(to:end)
				start = end
				end = CGPoint(x: originPoint.x + keyFrames[2].x,
							  y: originPoint.y + keyFrames[2].y)
				
				let keyProgress = CGFloat(Math.clamp(Double((progress - 0.5)  * 2.0)))
				path.addLine(to: Math.lerp(a: start, b: end, t: keyProgress))
				
			}
			context?.setStrokeColor(UIColor(named:"Primary Info")!.cgColor)
			path.stroke()
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
