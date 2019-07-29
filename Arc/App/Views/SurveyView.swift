//
//  SurveyView.swift
//  Arc
//
//  Created by Philip Hayes on 6/25/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation
import ArcUIKit
import HMMarkup


open class SurveyView : ACTemplateView, SurveyInput, SurveyInputDelegate {
	
	
	
	public weak var inputDelegate: SurveyInputDelegate?

	public var orientation: UIStackView.Alignment = .top
	var nextPressed:((SurveyInput?, QuestionResponse?)->Void)?
	var templateHandler:((String)->Dictionary<String,String>)?
	var questionPresented:((SurveyInput?)->Void)?
	var question:Survey.Question?

	
	var error:String?
	

	var container:UIStackView!
	var errorLabel:UILabel!

	var top:PromptDetailView!
	var input:SurveyInput?
	var views:UIStackView!
	
	
	
	override public init() {
		super.init()
		
		self.backgroundColor = .white
		
	}
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	//MARK: - Layout
	open override func header(_ view: UIView) {
		
	}
	override open func content(_ view: UIView) {
		super.content(view)
		view.stack { [weak self] in
			$0.axis = .vertical
			self?.top = $0.promptDetail {_ in}
			
			$0.setCustomSpacing(20, after: top)
			
			//Container stack for questions
			$0.stack {
				
				container = $0.stack {
					$0.axis = .horizontal
					$0.distribution = .equalCentering
					
				}
			}
			//
			//The error label below an input
			self?.errorLabel = $0.label {
				Roboto.Style.error($0)
				$0.text = ""
				
			}
		}
		
	}
	open override func footer(_ view: UIView) {
		
		//A container for miscelaneous views
		self.views = view.stack {
			$0.axis = .vertical
			$0.alignment = .center
			$0.isLayoutMarginsRelativeArrangement = true
			$0.layoutMargins.bottom = 20
			input?.supplementaryViews(for: views)
			
			$0.layout {
				$0.height == 20 ~ 250
				$0.height >= 20 ~ 999
			}
		}
		view.stack { [weak self] in
			$0.axis = .vertical
			$0.alignment = .center
			
			self?.nextButton = $0.acButton {
				$0.translatesAutoresizingMaskIntoConstraints = false
				$0.setTitle("Next", for: .normal)
				
				$0.addAction { [weak self] in
					let value = self?.input?.getValue()
					
					self?.inputDelegate?.nextPressed(input: self?.input, value: value)
				}
			}
		}
	}
	
	
	private func baseStyle(_ label:UILabel) {
		Roboto.PostProcess.renderMarkup(label)
	}
	
	
	// MARK: - Question Display
	/// Display Question sets the main prompt text, detail text, and input for a question.
	/// The button text is also handled via the question data along with other metadata for specific settings.
	///
	/// - Parameter question: An object of type Survey.Question.
	/// This value is created via Json files loaded by the parent SurveyNavigationViewController
	/// - Parameter template: A template for replacing variable words in question prompts
	func displayQuestion(withQuestion question: Survey.Question, template:[String:String] = [:]){

		top.setPrompt(question.prompt, template: template)
		top.separatorWidth = 0
		top.setDetail(question.detail)
		
		//If theres an image set it here.
		if let nextButtonImage = question.nextButtonImage {
			nextButton?.setImage(UIImage(named: nextButtonImage), for: .normal)
		} else {
			nextButton?.setImage(nil, for: .normal)
		}
	
		configureInput(question: question)

		
		
		inputDelegate?.didFinishSetup()
		
	}
	
	
	func updateButtonState(_ question:Survey.Question?) {
		if question?.style == .impasse {
			nextButton?.isHidden = true
		} else {
			nextButton?.isHidden = false
		}
		var altTitle = "NEXT".localized("button_next")
		var title = "NEXT".localized("button_next")
		if let nextButtonTitle = question?.nextButtonTitle {
			title = nextButtonTitle.localized(nextButtonTitle)
		} else {
			if question?.nextButtonImage != nil {
				title = ""
			}
		}
		if let nextButtonTitle = question?.altNextButtonTitle {
			altTitle = nextButtonTitle.localized(nextButtonTitle)
		} else {
			if question?.nextButtonImage != nil {
				altTitle = ""
			}
		}
		if self.input?.getValue()?.value == nil {
			self.disableNextButton(title: altTitle)
		} else {
			self.enableNextButton(title: title)
		}
		
	}
	
	public func configureInput(question:Survey.Question?) {
		guard input == nil else {
			return
		}
		input = question?.type?.create(inputWithQuestion: question)
		input?.inputDelegate = self
		input?.parentScrollView = root
		container.alignment = input?.orientation ?? .top
		if container.arrangedSubviews.isEmpty, let input = input as? UIView {
			container.addArrangedSubview(input)
		}
		views.removeSubviews()
		input?.supplementaryViews(for: views)
		updateButtonState(question)

	}
	public func enableNextButton(title:String = "Next")
	{
		self.nextButton?.isEnabled = true;
		self.nextButton?.alpha = 1;
		
		self.nextButton?.setTitle(title, for: .normal)
	}
	
	public func disableNextButton(title:String = "Next")
	{
		self.nextButton?.isEnabled = false;
		self.nextButton?.alpha = 0.5;
		self.nextButton?.setTitle(title, for: .normal)
	}
	
	
	//MARK: - Survey Input
	public func getValue() -> QuestionResponse? {
		return input?.getValue()
	}
	
	public func setValue(_ value: QuestionResponse?) {
		input?.setValue(value)
	}
	public func setError(message: String?) {
		input?.setError(message: message)
		errorLabel.text = message
	}
	public func didChangeValue() {
		inputDelegate?.didChangeValue()
		self.updateButtonState(question)
		
	}
	
	public func nextPressed(input: SurveyInput?, value: QuestionResponse?) {
		inputDelegate?.nextPressed(input: input, value: value)
	}
	
	
	public func templateForQuestion(id: String) -> Dictionary<String, String> {
		return inputDelegate?.templateForQuestion(id: id) ?? [:]
	}
	
	
	public func didFinishSetup() {
		inputDelegate?.didFinishSetup()
		self.updateButtonState(question)
	}
	
	public func tryNextPressed() {
		if self.nextButton?.isEnabled == true {
			if let value = self.input?.getValue() {
				inputDelegate?.nextPressed(input: self.input, value: value)
			} else {
				inputDelegate?.nextPressed(input: nil, value: nil)
			}
		}
	}
}