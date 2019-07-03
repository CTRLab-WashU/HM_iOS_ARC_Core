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
open class SurveyView : ACTemplateView, SurveyInput {
	
	
	public var orientation: UIStackView.Alignment = .top
	var nextPressed:((SurveyInput?, QuestionResponse?)->Void)?
	var templateHandler:((String)->Dictionary<String,String>)?
	var questionPresented:((SurveyInput?)->Void)?

	public var didFinishSetup: (() -> ())?
	public var didChangeValue: (() -> ())?
	public var tryNext: (() -> ())?
	
	
	

	var container:UIStackView!
	var errorLabel:UILabel!
	var promptLabel: UILabel!
	var detailsLabel:UILabel!
	
	var input:SurveyInput?
	var views:UIStackView!
	
	
	
	override public init() {
		super.init()
		
		self.backgroundColor = .white
		
	}
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func getValue() -> QuestionResponse? {
		return input?.getValue()
	}
	
	public func setValue(_ value: QuestionResponse?) {
		input?.setValue(value)
	}

	private func baseStyle(_ label:UILabel) {
		Roboto.PostProcess.renderMarkup(label)
	}
	
	public func setError(message: String?) {
		input?.setError(message: message)
		errorLabel.text = message
	}
	// MARK: - Question Display
	/// Display Question sets the main prompt text, detail text, and input for a question.
	/// The button text is also handled via the question data along with other metadata for specific settings.
	///
	/// - Parameter question: An object of type Survey.Question.
	/// This value is created via Json files loaded by the parent SurveyNavigationViewController
	func displayQuestion(withQuestion question: Survey.Question){

		
		renderer = HMMarkupRenderer(baseFont: promptLabel.font)
		let template = templateHandler?(question.questionId) ?? [:]
		let markedUpString = renderer.render(text: question.prompt, template:template)
		promptLabel.attributedText = markedUpString
		detailsLabel.text = question.detail
		
		//If theres an image set it here.
		if let nextButtonImage = question.nextButtonImage {
			nextButton?.setImage(UIImage(named: nextButtonImage), for: .normal)
		} else {
			nextButton?.setImage(nil, for: .normal)
		}
	
		configureInput(question: question)

		renderer = HMMarkupRenderer(baseFont: promptLabel.font)
		
		self.didFinishSetup?()
		self.questionPresented?(input)
	}
	
	
	func updateButtonState(_ question:Survey.Question?) {
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
		input = question?.type.create(inputWithQuestion: question)
		input?.tryNext = { [weak self] in
			if self?.nextButton?.isEnabled == true {
				self?.nextPressed?(nil, nil)
			}
		}
		
		input?.didChangeValue = { [weak self] in
			
			self?.updateButtonState(question)
			self?.didChangeValue?();
		}
		input?.didFinishSetup = { [weak self] in
			self?.updateButtonState(question)
		}
		
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
	
	
	override open func content(_ view: UIView) {
		super.content(view)
		view.stack { [weak self] in
			$0.spacing = 8
			$0.axis = .vertical
			$0.alignment = .fill
			$0.isLayoutMarginsRelativeArrangement = true
			$0.layoutMargins = UIEdgeInsets(top: 24,
											left: 24,
											bottom: 24,
											right: 24)
			let v = $0
			v.layout {
				
				// select an anchor give a priority of 999 (almost Required)
				$0.top == v.superview!.topAnchor ~ 999
				$0.trailing == v.superview!.trailingAnchor ~ 999
				$0.bottom == v.superview!.bottomAnchor ~ 999
				$0.leading == v.superview!.leadingAnchor ~ 999
				$0.width == self!.widthAnchor ~ 999
				$0.height >= self!.safeAreaLayoutGuide.heightAnchor ~ 500
			}

			let top = $0.stack {
				$0.axis = .vertical
				$0.alignment = .fill

				$0.spacing = 20
				self?.promptLabel = $0.acLabel {
					$0.text = ""
					Roboto.Style.heading($0)


				}
				self?.detailsLabel = $0.acLabel {
					
					Roboto.Style.body($0)
					$0.text = ""

				}
			}
			$0.setCustomSpacing(20, after: top)
			//Container stack for questions
			$0.stack {
				
				container = $0.stack {
					$0.axis = .horizontal
					
				}
			}
//				
			//The error label below an input
			self?.errorLabel = $0.label {
				Roboto.Style.error($0)
				$0.text = ""

			}
			
			$0.view {
				$0.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .vertical)
			}
			//A container for miscelaneous views
			self?.views = $0.stack {
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
			
			$0.stack { [weak self] in
				$0.axis = .vertical
				$0.alignment = .center
				
				self?.nextButton = $0.acButton {
					$0.translatesAutoresizingMaskIntoConstraints = false
					$0.setTitle("Next", for: .normal)
					
					$0.addAction { [weak self] in
						let value = self?.input?.getValue()
						
						self?.nextPressed?(self?.input, value)
					}
				}
			}
		}
	}
}
