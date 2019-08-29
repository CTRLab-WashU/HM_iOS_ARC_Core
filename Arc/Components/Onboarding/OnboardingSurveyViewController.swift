//
//  OnboardingSurveyViewController.swift
//  Arc
//
//  Created by Philip Hayes on 7/16/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit

public class OnboardingSurveyViewController: BasicSurveyViewController {

	override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	public override func customViewController(forQuestion question: Survey.Question) -> UIViewController? {
		if question.state == "NotificationAccess" {
			return NotificationPermissionViewController()
		}
		return nil
	}
	
	public override func valueSelected(value: QuestionResponse, index: String) {
		super.valueSelected(value: value, index: index)
		if index == "commitment" {
			if let value:Int = value.getValue() {
				if value == 0 {
					app.appController.commitment = .committed
				} else if value == 1 {
					app.appController.commitment = .rebuked
				}
			
			}
		}
	}
	public override func isValid(value: QuestionResponse?, questionId: String, didFinish: @escaping ((Bool) -> ())) {
	
		super.isValid(value: value, questionId: questionId) {valid in
			
			
			if questionId == "commitment" {
				if value?.value == nil {
					didFinish(false)
					return
				} else {
					didFinish(true)
					return
				}
			}
			else if questionId == "allow_from_settings" {
				if Await(checkNotificationStatus).execute(()) {
					didFinish(true)
				} else {
					guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
						didFinish(false)
						return
					}
					
					if UIApplication.shared.canOpenURL(settingsUrl) {
						UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
							print("Settings opened: \(success)") // Prints true
						})
					}
					didFinish(false)
				}
			}
			else {
				didFinish(true)
			}
		}
		
	}
	
	
	
}
fileprivate func checkNotificationStatus(void:Void, didFinish: @escaping (Bool)->()) {
	//A long running request
	Arc.shared.notificationController.authenticateNotifications { (granted, error) in
		OperationQueue().addOperation {
			didFinish(granted)
		}
	}
}
