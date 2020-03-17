//
//  ACStudyTotalsViewController.swift
//  Arc
//
//  Created by Philip Hayes on 3/17/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import UIKit
public class ACStudyTotalsViewController: CustomViewController<ACStudyTotalsView> {
	public override var prefersStatusBarHidden: Bool {return true}

    override public func viewDidLoad() {
        super.viewDidLoad()
		viewRespectsSystemMinimumLayoutMargins = false
        // Do any additional setup after loading the view.
		customView.set(studySummary: StudySummary.test)
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

