//
//  NotificationsRejected.swift
//  Arc
//
//  Created by Philip Hayes on 2/20/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import Foundation
import ArcUIKit
class NotificationsRejectedViewController : CustomViewController<InfoView>, SurveyInput {
	var useDarkStatusBar:Bool = false
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return useDarkStatusBar ? .default : .lightContent
    }
	
	var orientation: UIStackView.Alignment = .top

	
	var surveyInputDelegate: SurveyInputDelegate?
	
	
	
	func getValue() -> QuestionResponse? {
		return nil
	}
	
	func setValue(_ value: QuestionResponse?) {
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
        useDarkStatusBar = false
        setNeedsStatusBarAppearanceUpdate()
		customView.addSpacer()

        customView.backgroundView.image = UIImage(named: "availability_bg", in: Bundle(for: self.classForCoder), compatibleWith: nil)
		customView.infoContent.alignment = .center
		customView.backgroundColor = UIColor(named:"Primary")!
		customView.setTextColor(UIColor(named: "Secondary Text"))
        
		
		
		customView.setButtonColor(style:.secondary)
		
		customView.nextButton?.setTitle("".localized(ACTranslationKey.button_settings), for: .normal)
		customView.nextButton?.addAction {  [weak self] in
			guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
				return
			}
			
			if UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
					print("Settings opened: \(success)") // Prints true
				})
			}
			
		}
		customView.setHeading("".localized(ACTranslationKey.onboarding_notifications_header2))
		
		customView.setContentLabel("".localized(ACTranslationKey.onboarding_notifications_body2_ios)
			.replacingOccurrences(of: "{APP NAME}", with: "EXR"))
		
		customView.getContentLabel().textAlignment = .center
		
		
		
		customView.addSpacer()
		
		let button1 = ACButton()
		
		button1.primaryColor = .clear
		button1.secondaryColor = .clear
		button1.topColor = .clear
		button1.bottomColor = .clear
		button1.setTitle("Proceed Without Notifications", for: .normal)
		Roboto.PostProcess.link(button1)
		
		button1.addAction {  [weak self] in
			self?.surveyInputDelegate?.tryNextPressed()
		}
		customView.setAdditionalFooterContent(button1)
		

	}
	
	
}
