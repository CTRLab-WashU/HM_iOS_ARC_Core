//
//  NotificationPremissionViewController.swift
//  Arc
//
//  Created by Philip Hayes on 7/12/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit

class NotificationPremissionViewController: CustomViewController<NotificationPermissionView>, SurveyInput {
	
	public weak var inputDelegate: SurveyInputDelegate?

	var orientation: UIStackView.Alignment = .center
	
	var didFinishSetup: (() -> ())?
	
	var didChangeValue:(()->())? 
	
	var tryNext: (() -> ())?
	
	var _didAllow:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		Arc.shared.notificationController.authenticateNotifications { [weak self] (granted, error) in
			self?._didAllow = granted
			self?.inputDelegate?.didChangeValue()
		}
	}
	
	
	func getValue() -> QuestionResponse? {
		return AnyResponse(type: .choice, value: Int(_didAllow ? 1 : 0), textValue: String(_didAllow))
	}
	
	func setValue(_ value: QuestionResponse?) {
		
	}

}
