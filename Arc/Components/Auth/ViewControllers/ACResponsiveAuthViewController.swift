//
//  ACResponsiveAuthViewController.swift
//  Arc
//
//  Created by Philip Hayes on 12/16/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import UIKit

open class ACResponsiveAuthViewController: BasicSurveyViewController {

    var controller:AuthController = Arc.shared.authController
    var initialValue:String?
    var codeLength:Int = 6
    var loadedNewQuestions = false

    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        shouldNavigateToNextState = false
        shouldShowHelpButton = true
    }

    func helpHandler() {
        //        print("Navigate to help")
    }

    
    open override func didPresentQuestion(input: SurveyInput?, questionId: String)
    {
        let input = input

        if let view = input as? (SegmentedTextView) {
            view.set(length: 6)

        }

        if questionId == "auth_arc" {

            if let initialValue = initialValue {
                input?.setValue(AnyResponse(type: .segmentedText,
                                            value: initialValue))
            }
        }

        if questionId == "auth_confirm" {

            if let initialValue = controller.getUserName() {
                input?.setValue(AnyResponse(type: .segmentedText,
                                            value: initialValue))
            }
//            if let view = input as? SegmentedTextView {
//                view.shouldTryNext = false
//
//            }
        }
        if questionId == "2FA" {
            AuthHandler.TwoFactorPrep(surveyVc: self, input: input, userId: controller.getUserName() ?? "")
        }
        
        super.didPresentQuestion(input: input, questionId: questionId)
    }

    open override func isValid(value: QuestionResponse?, questionId: String, didFinish:@escaping ((Bool) -> Void))
    {
        super.isValid(value: value, questionId: questionId)
        { [weak self] valid in
            guard let weakSelf = self else{return}
            var valid = valid

            guard let value = value?.value as? String else {
                assertionFailure("Should be a string value")
                didFinish(false)
                return
            }
            if questionId == "auth_confirm"{
                if value != self?.initialValue {

                    self?.set(error:"Subject ID doesn’t match")
                    didFinish(false)
                    return

                }
                
            }
            if questionId == "auth_confirm" {
                if weakSelf.loadedNewQuestions {
                    didFinish(true)
                    return
                }
                AuthHandler.GetDetails(surveyVc: weakSelf, userId: value) {[weak self] (authDetails) in
                    guard let weakSelf = self else{return}

                    if let details = authDetails, details.response.success == true {
                        weakSelf.handleAuth(authDetails: details)
                        didFinish(true)
                    } else {
                        Arc.shared.displayAlert(message: "Handling errors is not yet set up.", options: [.default("Ok", {})])
                        didFinish(false)
                    }
                }
            }
            didFinish(true)
            return

        }
    }

    //Override this to write to other controllers
    override open func valueSelected(value:QuestionResponse, index:String) {
        //All questions are of type string in this controller
        guard let value = value.value as? String else {
            assertionFailure("Should be a string value")
            return
        }
        self.set(error: nil)

        if index == "auth_arc" {
            initialValue = value
        }
        
        if index == "auth_confirm" {
            if value == initialValue {
                _ = controller.set(username: value)
            }
            if initialValue != controller.getUserName() {

                self.set(error: "Subject ID does not match.")

            } else {
                
            }
        }
        
        if index == "2FA"
        {
            AuthHandler.TwoFactorAuth(surveyVc: self,
                                      input: nil,
                                      userId: initialValue ?? "",
                                      password: value)
        }
        
        if index == "auth_password" {
            AuthHandler.Auth(surveyVc: self,
                                      input: nil,
                                      userId: initialValue ?? "",
                                      password: value)
        }

    }
    
    func handleAuth(authDetails:AuthDetailsResponse) {
        guard loadedNewQuestions == false else { return}
        loadedNewQuestions = true
        var file = ""
        
        switch authDetails.response.auth_type {
        case .rater:
            file = "Auth-Additional"
            break
        case .confirm_code:
            file = "2FAuth-Addtional"

            break
        case .manual:
            file = "ManualAuth-Additional"

            break
            
       
        }
        
        let newSurvey = Arc.shared.surveyController.load(survey: file)
        questions += newSurvey.questions
        
        subQuestions = (subQuestions ?? []) + (newSurvey.subQuestions ?? [])
    }

}
