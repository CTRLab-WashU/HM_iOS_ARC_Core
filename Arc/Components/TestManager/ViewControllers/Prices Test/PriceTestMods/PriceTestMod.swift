//
//  PriceTestMod.swift
//  Arc
//
//  Created by Philip Hayes on 1/29/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import Foundation
import Arc
public struct PriceTestMod {
	
	
	public let closure: (PricesTestViewController) -> PricesTestViewController
	
	public func apply(to priceTest:PricesTestViewController) -> PricesTestViewController {
		closure(priceTest)
	}
}

