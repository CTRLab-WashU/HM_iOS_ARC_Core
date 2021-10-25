//
//  ACResponsiveAuthViewController.swift
//  Arc
//
//  Created by Philip Hayes on 12/16/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import UIKit
import CoreTelephony

open class ACResponsiveAuthViewController: BasicSurveyViewController {
    
    public static let US_REGION_CODE = "US"
    public static let US_COUNTRY_CODE = "+1"
    
    public static let UK_REGION_CODE = "GB" // (UK excluding Isle of Man)
    public static let UK_COUNTRY_CODE = "+44"
    
    public static func countryCode(from regionCode: String) -> String {
        switch regionCode {
        case ACResponsiveAuthViewController.UK_REGION_CODE:
            return ACResponsiveAuthViewController.UK_COUNTRY_CODE
        default:
            return ACResponsiveAuthViewController.US_COUNTRY_CODE
        }
    }
    
    public static func findRegionCode() -> String {
        if #available(iOS 12.0, *) {
            if let providers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders,
               let carrier = providers.values.first, let countryCode = carrier.isoCountryCode {
                return countryCode.uppercased()
            }
        } else {
            if let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider, let countryCode = carrier.isoCountryCode {
                return countryCode.uppercased()
            }
        }
        return US_REGION_CODE
    }

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
        if questionId == "2FAPhone" {
            let countryCode = ACResponsiveAuthViewController.countryCode(from: ACResponsiveAuthViewController.findRegionCode())
            input?.setValue(AnyResponse(type: .text,
                                        value: countryCode))
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
            if questionId == "auth_confirm" {
                if value != self?.initialValue {

                    self?.set(error:"Non-matching ARC ID".localized(ACTranslationKey.login_error4))
                    didFinish(false)
                    return

                }
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
                        didFinish(false)
                    }
                }
                
            } else if questionId == "2FAPhone" {
                let phoneNumber = "phone:\(value)"
                AuthHandler.GetDetails(surveyVc: weakSelf, userId: phoneNumber) {[weak self] (authDetails) in
                    guard let weakSelf = self else{return}

                    if let details = authDetails, details.response.success == true {
                        weakSelf.handleAuth(authDetails: details)
                        didFinish(true)
                    } else {
                        didFinish(false)
                    }
                }
            }
            else {
                didFinish(true)
            }
            
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
        
        if index == "auth_confirm" || index == "2FAPhone" {
            if value == initialValue {
                _ = controller.set(username: value)
            }
            if initialValue != controller.getUserName() {

                self.set(error: "Non-matching ARC ID".localized(ACTranslationKey.login_error4))

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
        case .phone_number_entry:
            loadedNewQuestions = false
            // We have switched to normal auth for this
            file = "Auth"

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
