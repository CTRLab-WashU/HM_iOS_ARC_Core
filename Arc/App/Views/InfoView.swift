//
//  TestIntroView.swift
//  Arc
//
//  Created by Philip Hayes on 7/8/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
import HMMarkup



public class InfoView: ACTemplateView {
	weak var inputDelegate:SurveyInputDelegate? {
		didSet {
			self.inputItem?.surveyInputDelegate = inputDelegate

		}
	}
	var infoContent:InfoContentView!
	var miscContainer:UIStackView!
	var additionalContent:UIStackView!
	var inputContainer:UIStackView!
	var errorLabel:UILabel!
	var topSpacer:UIView!
	var inputItem:SurveyInput? {
		didSet {
			self.inputItem?.surveyInputDelegate = inputDelegate
		}
	}
	public func setTextColor(_ color:UIColor?) {
		infoContent.textColor = color
	}
	public func setButtonColor(primary:UIColor?, secondary:UIColor?, textColor:UIColor) {
		nextButton?.primaryColor = primary!
		nextButton?.secondaryColor = secondary!
		nextButton?.setTitleColor(textColor, for: .normal)
		
	}
    public func enableNextButton(title:String = "Next") {
        nextButton?.isEnabled = true;
        nextButton?.alpha = 1;
        nextButton?.setTitle(title, for: .normal)
    }
    public func disableNextButton(title:String = "Next") {
        nextButton?.isEnabled = false;
        nextButton?.alpha = 0.5;
        nextButton?.setTitle(title, for: .normal)
    }
	public func setInput(_ view:(UIView & SurveyInput)?) {
		inputItem = view
		inputItem?.parentScrollView = root

		view?.supplementaryViews(for: self.miscContainer)
		if miscContainer.subviews.count > 0 {
			miscContainer.isHidden = false
		}
		inputContainer.removeSubviews()

		if let view = view {
			inputContainer.addArrangedSubview(view)
			inputContainer.alignment = inputItem?.orientation ?? .top
		} else {
			inputContainer.removeSubviews()
		}
	}
	public func setAdditionalContent(_ view:UIView?) {
		if let view = view {
			additionalContent.isHidden = false

			additionalContent.addArrangedSubview(view)
		} else {
			additionalContent.isHidden = true

			additionalContent.removeSubviews()
		}
	}
	public func setAdditionalFooterContent(_ view:UIView?) {
		if let view = view {
			miscContainer.isHidden = false
			miscContainer.addArrangedSubview(view)
			
		} else {
			miscContainer.isHidden = true

			miscContainer.removeSubviews()
		}
	}
	public func setError(message:String?) {
		errorLabel.text = message
		inputItem?.setError(message: message)
		if let _ = message {
			spacerView.isHidden = false
		}
	

	}
	public func setHeading(_ text:String?) {
		infoContent.setHeader(text)
	}
    public func setIntroHeading(_ text:String?){
        infoContent.setIntroHeader(text)
    }
	public func setSeparatorWidth(_ width:CGFloat) {
		infoContent.setSeparatorWidth(width)
	}
	public func addSpacer() {
		infoContent.addSpacer()
	}
	public func setSubHeading(_ text:String?) {
		infoContent.setSubHeader(text)

	}
    public func setPrompt(_ text:String?){
        infoContent.setPrompt(text)
    }
	public func setContentText(_ text:String?, template:[String:String] = [:]) {
		infoContent.setContent(text, template:template)

	}
    public func setIntroContentText(_ text:String?, template:[String:String] = [:]) {
        infoContent.setIntroContent(text, template:template)

    }
	public func setContentLabel(_ text:String?, template:[String:String] = [:]) {
		infoContent.setContentLabel(text, template:template)
		
	}
    public func getContentLabel() -> HMMarkupLabel {
        return (infoContent?.contentLabel!)!
    }
	override open func content(_ view: UIView) {
		super.content(view)
		
		topSpacer = view.view {
			$0.translatesAutoresizingMaskIntoConstraints = false
			$0.isHidden = true
			$0.setContentHuggingPriority(UILayoutPriority(200), for: .vertical)
		}
		
		infoContent = view.infoContent {_ in
		
		}
		inputContainer = view.stack {
			$0.axis = .horizontal
			$0.alignment = .top
			$0.spacing = 8

		}
		errorLabel = view.acLabel {
			Roboto.Style.error($0)
		}
		
		//Hide this view when not in use
		additionalContent = view.stack {
			$0.axis = .vertical
			$0.alignment = .fill
			$0.spacing = 20
			$0.isHidden = true
		}

	}
	
	public override func footer(_ view:UIView) {
		super.footer(view)
		view.stack { [weak self] in
			$0.axis = .vertical
			$0.alignment = .fill
			$0.spacing = 8
			
			//Use this container to insert views as seen fit
			self?.miscContainer = $0.stack {
				$0.axis = .vertical
				$0.accessibilityLabel = "Misc Container"
				$0.isHidden = true
			}
			self?.nextButton = $0.acButton {
				$0.primaryColor = UIColor(named:"Secondary")!
				$0.secondaryColor = UIColor(named:"Secondary Gradient")!
				$0.setTitleColor(UIColor(named:"Primary Text")!, for: .normal)
				$0.translatesAutoresizingMaskIntoConstraints = false
				$0.setTitle("Next", for: .normal)
				
			}
		}
	}
}
