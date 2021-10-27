//
//  AuthHandler.swift
//  Arc
//
//  Created by Philip Hayes on 12/17/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import Foundation
import HMMarkup

import UIKit

public struct AuthHandler {
    
    public static func addResendCodeButton(surveyVc:BasicSurveyViewController, userId:String) {
        if let vc:CustomViewController<InfoView> = surveyVc.getTopViewController() {
            let button = HMMarkupButton()
            
            //Unhide the spacer to prevent the did receive code button from sitting at the bottom of the view.
            vc.customView.spacerView.isHidden = false
            button.setTitle("Didn't receive code?".localized(ACTranslationKey.login_problems_2FA), for: .normal)
            button.setTitleColor(UIColor(named:"Primary"), for: .normal)
            Roboto.Style.bodyBold(button.titleLabel!)
            Roboto.PostProcess.link(button)
            button.contentHorizontalAlignment = .leading
            
            button.addAction {[weak surveyVc] in
                let vc:ResendCodeViewController = ResendCodeViewController(id: userId)
                surveyVc?.addController(vc)
            }
            vc.customView.setAdditionalContent(button)
        }
    }
    public static func TwoFactorPrep(surveyVc:BasicSurveyViewController, input: SurveyInput?, userId:String) {
        let view = input as? (SegmentedTextView)
        
        //This will prevent the input from triggering a next action when valid.
        view?.shouldTryNext = false
        view?.hideHelpButton = true
        addResendCodeButton(surveyVc:surveyVc, userId: userId)
            
        let vc:CustomViewController<InfoView> = surveyVc.getTopViewController()!
        // let label = vc.customView.getContentLabel()
        // vc.customView.setContentLabel(label.text!.replacingOccurrences(of: "{digits}", with: "5555"))
        vc.customView.setContentLabel("")
        
    }
    public static func TwoFactorAuth(surveyVc:BasicSurveyViewController, input:SurveyInput?, userId:String, password:String){
        _ = Arc.shared.authController.set(username: userId)
        _ = Arc.shared.authController.set(password: password)
       
        surveyVc.addSpinner(color: .white, backGroundColor: UIColor(named:"Primary"))

        Arc.shared.authController.authenticate { (id, error) in
            OperationQueue.main.addOperation {
                if let value = id {
                    surveyVc.set(error: nil)
                    Arc.shared.participantId = Int(value)
                    
                    surveyVc.hideSpinner()
                    
                    Arc.shared.nextAvailableState()

                } else {
                    surveyVc.set(error: error)
                    surveyVc.hideSpinner()
                }
            }
        }
    }
    public static func Auth(surveyVc:BasicSurveyViewController, input:SurveyInput?, userId:String, password:String){
        _ = Arc.shared.authController.set(username: userId)
        _ = Arc.shared.authController.set(password: password)
        
        surveyVc.addSpinner(color: .white, backGroundColor: UIColor(named:"Primary"))

        Arc.shared.authController.authenticate { (id, error) in
            OperationQueue.main.addOperation {
                if let value = id {
                    surveyVc.set(error: nil)
                    Arc.shared.participantId = Int(value)
                    
                    surveyVc.hideSpinner()
                    
                    Arc.shared.nextAvailableState()

                } else {
                    surveyVc.set(error: error)
                    surveyVc.hideSpinner()
                }
            }
        }
    }
    public static func GetDetails(surveyVc:BasicSurveyViewController, userId:String, completion:@escaping ((AuthDetailsResponse?) -> Void)) {
        
        if (Arc.environment?.blockApiRequests ?? false) == true
        {
            surveyVc.set(error:nil)
            var d = AuthDetailsResponse.debug
            completion(d)
            return;
        }
        
        let top:CustomViewController<InfoView>? = surveyVc.getTopViewController()

        top?.customView.nextButton?.showSpinner(color: UIColor(white: 1.0, alpha: 0.8), backgroundColor:UIColor(named:"Primary"))
        
        Arc.shared.authController.getAuthDetails(id: userId) { (status, authDetails) in
            OperationQueue.main.addOperation {
                top?.customView.nextButton?.hideSpinner()

                if let value = authDetails {
                    surveyVc.set(error:nil)
                    completion(authDetails)
                } else {
                    surveyVc.set(error:status.failureMessage)
                    completion(nil)
                }
            }
        }
    }
    
    static public func verifyParticipant(id:String, didFinish:@escaping (ACResult<String>)->()){
        Arc.shared.authController.resend2FACode(id: id, didFinish: didFinish)
    }
}
