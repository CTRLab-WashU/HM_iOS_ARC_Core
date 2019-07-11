//
//  PricesTestTutorialViewController.swift
//  Arc
//
//  Created by Philip Hayes on 7/3/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit

class PricesTestTutorialViewController: ACTutorialViewController, PricesTestDelegate {
	
	
	let pricesTest:PricesTestViewController = .get()
	var didSelectPrice1 = false
	var didSelectPrice2 = false
	
	var didRecalPrice1 = false
	var didRecalPrice2 = false
    override func viewDidLoad() {
        super.viewDidLoad()
		pricesTest.delegate = self
		pricesTest.autoStart = false

		state.addCondition(atTime: 0, flagName: "hide") { [weak self] in
			
			self?.pricesTest.priceDisplay.isHidden = true
		}
		state.addCondition(atTime: 0.02, flagName: "init") { [weak self] in
			self?.pricesTest.priceDisplay.isHidden = false

			self?.pricesTest.displayItem()
			self?.pricesTest.buildButtonStackView()
		}
		state.addCondition(atTime: 0.11, flagName: "overlay1") { [weak self] in
			
			self?.pricesTest.priceDisplay.overlay()
		}
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		addChild(pricesTest)
		customView.setContent(viewController: pricesTest)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		view.window?.clearOverlay()
	}
	
	func didSelectGoodPrice(_ option: Int) {
		view.window?.clearOverlay()

		didSelectPrice1 = true
		
		
	}

}
