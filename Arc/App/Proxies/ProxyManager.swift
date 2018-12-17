//
//  ProxyManager.swift
// Arc
//
//  Created by Philip Hayes on 10/18/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
open class ProxyManager {
	static public let shared = ProxyManager()
	
	
	
	public func apply() {
		UINavigationBarProxy().apply()
	}
}
