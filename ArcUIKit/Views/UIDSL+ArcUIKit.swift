//
//  UIDSL+ARC.swift
//  Arc
//
//  Created by Philip Hayes on 6/27/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation

extension UIView {
	@discardableResult
	public func acView(apply closure: (ACView) -> Void) -> ACView {
		custom(ACView(), apply: closure)
	}
	@discardableResult
	public func acButton(apply closure: (ACButton) -> Void) -> ACButton {
		custom(ACButton(), apply: closure)
	}
	@discardableResult
	public func acLabel(apply closure: (ACLabel) -> Void) -> ACLabel {
		custom(ACLabel(), apply: closure)
	}
	@discardableResult
	public func acTextView(apply closure: (ACTextView) -> Void) -> ACTextView {
		custom(ACTextView(), apply: closure)
	}
	@discardableResult
	public func scrollIndicator(apply closure: (IndicatorView) -> Void) -> IndicatorView {
		custom(IndicatorView(), apply: closure)
	}
	

	
	
}
