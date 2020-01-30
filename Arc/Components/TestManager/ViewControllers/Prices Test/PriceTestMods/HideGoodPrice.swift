//
//  HideGoodPrice.swift
//  Arc
//
//  Created by Philip Hayes on 1/29/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import Foundation
public extension PriceTestMod {
	static func hideGoodPrice(_ value:Bool) -> Self {
		return PriceTestMod { viewController in

			
			viewController.goodPriceLabel.isHidden = value
			viewController.buttonStack.isHidden = true
			
			return viewController
		}
	}
}
