//
//  CircularProgressGroupStackView.swift
//  Arc
//
//  Created by Philip Hayes on 8/13/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import ArcUIKit

public class ACCircularProgressGroupStackView : UIStackView {
	private var progressViews:[CircularProgressView] = []
	public var config = Drawing.CircularBar()

	public init() {
		super.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false
		axis = .horizontal
		
		distribution = .fillEqually
		spacing = 8
		
		

	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func addProgressViews(count:Int) {
		
		config.strokeWidth =  6
		config.trackColor = #colorLiteral(red: 0.400000006, green: 0.7799999714, blue: 0.7799999714, alpha: 1)
		config.barColor = #colorLiteral(red: 0.04300000146, green: 0.1220000014, blue: 0.3330000043, alpha: 1)
		
		for _ in 0 ..< count {
			progressViews.append (circularProgress {
				$0.config = config
				$0.progress = 0
			})
		}
	}
	public func set(progress:Double, for index:Int) {
		progressViews[index].progress = progress
	}
	public func clearProgressViews() {
		removeSubviews()
		progressViews = []
	}
}
extension UIView {
	
	@discardableResult
	public func circularProgressGroup(apply closure: (ACCircularProgressGroupStackView) -> Void) -> ACCircularProgressGroupStackView {
		return custom(ACCircularProgressGroupStackView(), apply: closure)
	}
	
}
