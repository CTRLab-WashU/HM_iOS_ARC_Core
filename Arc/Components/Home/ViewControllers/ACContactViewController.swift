//
//  ContactViewController.swift
// Arc
//
//  Created by Philip Hayes on 10/23/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
import MessageUI
open class ACContactViewController: UIViewController, MFMailComposeViewControllerDelegate {
	var returnState:State = Arc.shared.appNavigation.previousState() ?? Arc.shared.appNavigation.defaultState()
	var returnVC:UIViewController?
	@IBOutlet weak var aboutButton:UIButton!
	@IBOutlet weak var privacyButton:UIButton!
	
	override open func viewDidLoad() {
		super.viewDidLoad()
	}
	
	
	
	
}
