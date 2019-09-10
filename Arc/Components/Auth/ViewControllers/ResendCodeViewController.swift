//
//  ResendCodeViewController.swift
//  Arc
//
//  Created by Philip Hayes on 7/26/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import HMMarkup
import ArcUIKit
class ResendCodeViewController: CustomViewController<InfoView>, SurveyInput{
	
	
	var orientation: UIStackView.Alignment = .top

	
	var surveyInputDelegate: SurveyInputDelegate?
	
	var participantId:String
	init(id:String) {
		participantId = id
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func addNeedMoreHelpButton() {
		//Unhide the spacer to prevent the button from sitting at the bottom of the view.
		customView.spacerView.isHidden = false
		let button = HMMarkupButton()
		
		button.setTitle("I need more help", for: .normal)
		button.setTitleColor(UIColor(named:"Primary"), for: .normal)
		Roboto.Style.bodyBold(button.titleLabel!)
		Roboto.PostProcess.link(button)
		button.contentHorizontalAlignment = .leading
		
        button.addAction {[weak self] in
            //self?.nextPressed(input: self?.getInput(), value: AnyResponse(type: .text, value: "0"))
            self?.pressedNeedMoreHelp()
        }
        customView.setAdditionalContent(button)
	}
	
	fileprivate func addSendNewCodeButton() {
		let sendCodeButton = ACButton()
		sendCodeButton.setTitle("SEND NEW CODE", for: .normal)
		sendCodeButton.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
		customView.setAdditionalContent(sendCodeButton)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		customView.setTextColor(UIColor(named:"Primary Text"))
		customView.setHeading("login_resend_header")
		customView.setContentLabel("login_resend_subheader")
		customView.nextButton?.isHidden = true
		
		
		addSendNewCodeButton()
		
		addNeedMoreHelpButton()
    }
    
    func pressedNeedMoreHelp() {
        let vc:AC2FAHelpViewController = .get()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
	@objc func sendCode() {
		
		let nav = navigationController
		let id = participantId
		MHController.dataContext.perform {
			
			let result:ACResult<String> = Await(TwoFactorAuth.verifyParticipant).execute(id)
			switch result {
			case .error(_):
				break;
				
			case .success(_):
				OperationQueue.main.addOperation {
					nav?.popViewController(animated: true)

				}
				
			}
		}
	}
	func getValue() -> QuestionResponse? {
		return nil
	}
	
	func setValue(_ value: QuestionResponse?) {
		
	}

}
