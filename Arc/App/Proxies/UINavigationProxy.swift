//
//  UINavigationProxy.swift
// Arc
//
//  Created by Philip Hayes on 10/18/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
open class Proxy {
	open func apply() {
		
	}
}

open class UINavigationBarProxy : Proxy {
	override open func apply() {
		super.apply()
		
		UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().isTranslucent = true
		UINavigationBar.appearance().tintColor = UIColor(named: "Primary")
	}
}
