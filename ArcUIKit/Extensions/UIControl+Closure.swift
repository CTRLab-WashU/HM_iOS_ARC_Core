//
//  UIControl+Closure.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 6/27/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
class ClosureSleeve {
	let closure: () -> ()
	
	init(attachTo: AnyObject, closure: @escaping () -> ()) {
		self.closure = closure
		objc_setAssociatedObject(attachTo, "[\(UUID().uuidString)]", self, .OBJC_ASSOCIATION_RETAIN)
	}
	
	@objc func invoke() {
		closure()
	}
}

extension UIControl {
	public func addAction(for controlEvents: UIControl.Event = .primaryActionTriggered, action: @escaping () -> ()) {
		let sleeve = ClosureSleeve(attachTo: self, closure: action)
		addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
	}
	
}
