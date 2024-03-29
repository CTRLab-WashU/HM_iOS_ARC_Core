//
//  ACAuthViewController.swift
//  Arc
//
//  Created by Philip Hayes on 1/14/19.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
open class ACAuthViewController: SurveyNavigationViewController {

	var controller:AuthController = Arc.shared.authController
	var initialValue:String?
	override open func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		shouldNavigateToNextState = false
		shouldShowHelpButton = true
	}
	override open func loadSurvey(template:String) {
		survey = Arc.shared.surveyController.load(survey: template)
		
		
		//Shuffle the questions
		questions = survey?.questions ?? []
		
		
		
	}
	func helpHandler() {
//		print("Navigate to help")
	}
	override open func onQuestionDisplayed(input:SurveyInput, index:String) {
		var input = input
		if index == "auth_1" {
//            if let view = input as? SegmentedTextView {
//                view.set(length: 8)
//                view.insert(spaceAtIndex: 4, ofSize: 30)
//            }
            if let initialValue = initialValue {
                input.setValue(AnyResponse(type: .segmentedText,
                                           value: initialValue))
            }
		} else if index == "auth_2" {
//            if let view = input as? SegmentedTextView {
//                view.set(length: 8)
//                view.insert(spaceAtIndex: 4, ofSize: 30)
//            }
            if let initialValue = controller.getUserName() {
                input.setValue(AnyResponse(type: .segmentedText,
                                           value: initialValue))
            }
		} else if index == "auth_3" {
			//Try next will trigger the next button if not nil
			//We don't want to fire this for the final step (#9016)
			input.tryNext = nil
            if let view = input as? SegmentedTextView {
                view.set(length: 5)
            }
            if let pass = controller.getPassword() {
                input.setValue(AnyResponse(type: .segmentedText,
                                           value: pass))
            }
		}
		
	}
	
	override open func isValid(value:QuestionResponse, index: String) -> Bool {
        guard let value = value.value as? String else {
            assertionFailure("Should be a string value")
            return false
        }
        if index == "auth_2", let input:SurveyInput = self.topViewController as? SurveyInput {
            if value != initialValue {
                input.setError(message:"Subject ID doesn’t match")
                return false
            }
        }
		return true
	}
	
	//Override this to write to other controllers
	override open func onValueSelected(value:QuestionResponse, index:String) {
		//All questions are of type string in this controller
		guard let value = value.value as? String else {
			assertionFailure("Should be a string value")
			return
		}

		if index == "auth_1" {
			initialValue = value
		} else if index == "auth_2" {
			if value == initialValue {
				_ = controller.set(username: value)
			}
		} else if index == "auth_3" {
			_ = controller.set(password: value)

			if initialValue != controller.getUserName() {
				if let input:SurveyInput = self.topViewController as? SurveyInput {
					input.setError(message:"Subject ID does not match.")
				}
			} else {
				if let top = self.topViewController as? SurveyViewController {
					top.nextButton.showSpinner(color: UIColor(white: 1.0, alpha: 0.8), backgroundColor:UIColor(named:"Primary") )
				}
				controller.authenticate { (id, error) in
					OperationQueue.main.addOperation {
						if let value = id {
							if let input:SurveyInput = self.topViewController as? SurveyInput {
								input.setError(message: nil)
							}
							Arc.shared.participantId = Int(value)

							if let top = self.topViewController as? SurveyViewController {
								top.nextButton.hideSpinner()
							}

							Arc.shared.nextAvailableState()

						} else {
							if let input:SurveyInput = self.topViewController as? SurveyInput {
								input.setError(message:error)
								if let top = self.topViewController as? SurveyViewController {
									top.nextButton.hideSpinner()
								}
							}
						}
					}
				}
			}
		}
		
	}
	
	
	


}
