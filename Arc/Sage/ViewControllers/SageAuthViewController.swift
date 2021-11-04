//
//  SageAuthViewController.swift
//  Arc
//
//  Copyright © 2021 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit

public class SageAuthViewController : BasicSurveyViewController {
    var controller:AuthController = Arc.shared.authController
    var initialValue:String = ""
	
    public let maxCharactersVerificationCode: UInt = 9
    
    public override init(file: String, surveyId:String? = nil, showHelp:Bool? = true) {
		super.init(file: file)
		
		shouldNavigateToNextState = false
		
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
    func helpHandler() {
        //        print("Navigate to help")
    }
	open override func didPresentQuestion(input: SurveyInput?, questionId: String) {
		
         let input = input
        if questionId == "auth_arc" {
            
		
			
            if let view = input as? SegmentedTextView {
                view.set(length: 6)
            }
            
            input?.setValue(AnyResponse(type: .segmentedText,
                                       value: initialValue))
            
        } else if questionId == "auth_sign_in_token" {
            
            if let view = input as? SegmentedTextView {
                view.set(length: maxCharactersVerificationCode)
                view.keyboardType = .default
            }
            if let view = input as? MultilineTextView {
                view.maxCharacters = Int(maxCharactersVerificationCode)
                view.textView.keyboardType = .default
                view.textView.autocorrectionType = .no
                view.textView.returnKeyType = .done
                view.textView.autocapitalizationType = .none
                view.textView.smartDashesType = .no
                view.textView.smartQuotesType = .no
                view.textView.smartInsertDeleteType = .no
            }
            input?.setValue(AnyResponse(type: .segmentedText,
                                       value: nil))
            
        } else if questionId == "auth_rater" {
            
			
            if let view = input as? SegmentedTextView {
                view.set(length: 6)
            }
            if let pass = controller.getPassword() {
                input?.setValue(AnyResponse(type: .segmentedText,
                                           value: pass))
            }
        } else if questionId == "auth_confirm" {
            //Try next will trigger the next button if not nil
            //We don't want to fire this for the final step (#9016)

            if let view = input as? SegmentedTextView {
				view.shouldTryNext = false
                view.set(length: 6)
            }
            if let userName = controller.getUserName() {
                input?.setValue(AnyResponse(type: .segmentedText,
                                           value: userName))
            }
        }
        
    }
    
	public override func isValid(value: QuestionResponse?, questionId: String, didFinish: @escaping ((Bool) -> ())){
		
		
		guard let value = value?.value as? String else {
            //assertionFailure("Should be a string value")
            didFinish(false)
			return
        }
		if questionId == "auth_confirm" {
			if initialValue != value {
				set(error:"Map ID does not match.".localized(ACTranslationKey.login_error4))
				didFinish(false)

				return
			   
			}
		}
        didFinish(true)
    }
    
    //Override this to write to other controllers
    override open func valueSelected(value:QuestionResponse, index:String) {
        //All questions are of type string in this controller
            
		set(error:nil)
		guard let value = value.value as? String else {
            assertionFailure("Should be a string value")
            return
        }
        
        if index == "auth_arc"
        {
            initialValue = value
			
        }
        else if index == "auth_rater"
        {
			initialValue = ""
			controller.clear()
            _ = controller.set(password: value)

          

        } else if index == "auth_confirm" {
            if initialValue != value {
				set(error:"Map ID does not match.".localized(ACTranslationKey.login_error4))
				return
               
            } else {

				set(error:nil)
				_ = controller.set(username: value)
            }
			
			guard let _ = controller.getUserName(), let _ = controller.getPassword() else { return; }
			
			addSpinner()
			
			controller.authenticate { (id, error) in
				OperationQueue.main.addOperation {
					if let value = id {
						
						self.set(error:nil)
						
						Arc.shared.participantId = Int(value)
						
						self.hideSpinner()
						
						Arc.shared.nextAvailableState()

					} else {
						
						self.set(error:error)
						
						self.hideSpinner()
					
					}
				}
			}
        } else if index == "auth_sign_in_token" {
            set(error:nil)
            _ = controller.set(username: initialValue)
            _ = controller.set(password: value)
            
            self.view.endEditing(true)
            addSpinner()
            
            controller.authenticate { (id, error) in
                OperationQueue.main.addOperation {
                    if let value = id {
                        
                        self.set(error:nil)
                        
                        Arc.shared.participantId = Int(value)
                        
                        self.hideSpinner()
                        
                        Arc.shared.nextAvailableState()

                    } else {
                        var errorStr = "Account not found".localized(ACTranslationKey.login_error1)
                        
                        // Skip this error message, as it is the generic one
                        if error != "Account not found." {
                            errorStr = "\(errorStr)\n\(error ?? "")"
                        }
                        
                        self.set(error:errorStr)
                        
                        self.hideSpinner()
                    
                    }
                }
            }
        }
        
    }
}
