//
//  PricesTestTutorialViewController.swift
//  Arc
//
//  Created by Philip Hayes on 7/3/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit

class PricesTestTutorialViewController: ACTutorialViewController {
	let pricesTest = PricesTestViewController.get()
    override func viewDidLoad() {
        super.viewDidLoad()
		customView.setContent(viewController: pricesTest)
		
		
		state.addCondition(atTime: 0.1, flagName: "start", onFlag: { [weak self] in
			self?.pauseTutorialAnimation()
			print("oi")
		})
		
		
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
