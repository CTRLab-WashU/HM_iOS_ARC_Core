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
	public override func isValid(value: QuestionResponse?, questionId: String) -> Bool {
		var valid = super.isValid(value: value, questionId: questionId)
		
		if questionId == "allow_from_settings" {
			if Await(checkNotificationStatus).execute(()) {
				valid = true
			} else {
				valid = false
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
					return false
				}
				
				if UIApplication.shared.canOpenURL(settingsUrl) {
					UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
						print("Settings opened: \(success)") // Prints true
					})
				}
			}
		}
		return valid
	}
	func checkNotificationStatus(void:Void, didFinish: @escaping (Bool)->()) {
		//A long running request
		Arc.shared.notificationController.authenticateNotifications { (granted, error) in
			OperationQueue().addOperation {
				didFinish(granted)
			}
			
		}
		
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
