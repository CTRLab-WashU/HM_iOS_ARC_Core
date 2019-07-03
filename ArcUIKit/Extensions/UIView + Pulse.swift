//
//  UIView + Pulse.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 7/2/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation
import QuartzCore

func createAnimatedLayer(from view: UIView, strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
	let layer = CAShapeLayer()
	//    let path = OverlayShape.rect(view).path()
	let path = OverlayShape.roundedRect(view, 8.0).path()
	layer.frame = view.bounds
	layer.path = path.cgPath
	layer.strokeColor = strokeColor.cgColor
	layer.lineWidth = 2
	layer.fillColor = fillColor.cgColor
	layer.lineCap = CAShapeLayerLineCap.round
	
	
	
	layer.zPosition = 100
	return layer
}

extension CALayer {
	func animatePulsingBorder(to scale:Double = 1.3, for duration: Double = 1.0, looping:Bool = true) {
		//scale animation
		let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
		scaleAnimation.toValue = scale
		scaleAnimation.duration = duration
		scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		
		//opacity animation
		let opacityAnimation = CABasicAnimation(keyPath: "opacity")
		opacityAnimation.fromValue = 1.0
		opacityAnimation.toValue = 0.0
		opacityAnimation.duration = duration
		opacityAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		
		if looping {
			scaleAnimation.repeatCount = Float.infinity
			opacityAnimation.repeatCount = Float.infinity
		}
		
		self.add(scaleAnimation, forKey: "pulsing")
		self.add(opacityAnimation, forKey: "opacity")
		
	}
}

extension UIView {
	
	static var highlightId:Int {
		get {
			return 666420
		}
	}
	
	public func highlight(highlightColor color:UIColor = .yellow, toScale scale:Double = 1.3, forDuration duration: Double = 1.0, looping:Bool = true) {
		let newView = OverlayView()
		newView.tag = UIView.highlightId
		newView.backgroundColor = .clear
		
		self.window?.addSubview(newView)
		newView.frame = self.convert(self.bounds, to: nil)

		let animatedLayer = createAnimatedLayer(from: newView, strokeColor: color, fillColor: .clear)
		animatedLayer.animatePulsingBorder(to: scale, for: duration, looping: looping)
		newView.layer.addSublayer(animatedLayer)
	}
	public func removeHighlight() {
		self.window?.subviews.first { (v) -> Bool in
			return v.tag == UIView.highlightId && v.frame == self.frame
			}?.removeFromSuperview()
	}
	public func hasHighlight() -> Bool {
		guard let window = window else { return false }
		return window.subviews.contains {
			$0.tag == UIView.highlightId && $0.frame == self.frame
		}
	}
	public func getTopLevelView() -> UIView {
		var view = self
		while let parent = view.superview {
			view = parent
		}
		
		return view
	}
}
