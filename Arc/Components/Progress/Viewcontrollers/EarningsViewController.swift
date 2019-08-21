//
//  EarningsViewController.swift
//  Arc
//
//  Created by Philip Hayes on 8/14/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit

public class EarningsViewController: CustomViewController<ACEarningsView> {


	override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		setGoal()
		
    }
	
	public func setGoal() {
		customView.earningsBodyLabel.text = "".localized(ACTranslationKey.earnings_body0)
		customView.bonusGoalsBodyLabel.text = "".localized(ACTranslationKey.earnings_bonus_body)
		
		
		
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
