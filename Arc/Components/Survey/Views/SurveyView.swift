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
open class SurveyView : UIView, SurveyInput {
	
	
	public var orientation: UIStackView.Alignment = .top
	var nextPressed:((SurveyInput?, QuestionResponse?)->Void)?

	public var didFinishSetup: (() -> ())?
	public var didChangeValue: (() -> ())?
	public var tryNext: (() -> ())?
	
	var renderer:HMMarkupRenderer!

	var container:UIStackView!
	var errorLabel:UILabel!
	var promptLabel: UILabel!
	var detailsLabel:UILabel!
	var nextButton:ACButton!
	var input:SurveyInput?
	var root:UIView!
	var views:UIStackView!
	var scrollIndicator: UIView!
	var scrollIndicatorLabel:UILabel!
	
	
	public init() {
		super.init(frame: .zero)
		
		self.backgroundColor = .white

		
	}
	private func baseStyle(_ label:UILabel) {
		Roboto.Style.renderMarkup(label)
		Roboto.Style.lineHeight(label)
	}
	public func setError(message: String?) {
		errorLabel.text = message
	}
	func displayQuestion(withQuestion question: Survey.Question?){
		build()
		promptLabel.text = question?.prompt
		detailsLabel.text = question?.detail
		
		//If theres an image set it here.
		if let nextButtonImage = question?.nextButtonImage {
			nextButton.setImage(UIImage(named: nextButtonImage), for: .normal)
		} else {
			nextButton.setImage(nil, for: .normal)
		}
		baseStyle(promptLabel)
		baseStyle(detailsLabel)
		configureInput(question: question)

		renderer = HMMarkupRenderer(baseFont: promptLabel.font)
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
			self?.nextPressed?(nil, nil)
		}
		
		input?.didChangeValue = { [weak self] in
			
			self?.updateButtonState(question)
			self?.didChangeValue?();
		}
		input?.didFinishSetup = { [weak self] in
			self?.updateButtonState(question)
		}
		input?.setError(message: nil)
		input?.parentScrollView = root as? UIScrollView
		container.alignment = input?.orientation ?? .top
		if container.arrangedSubviews.isEmpty, let input = input as? UIView {
			container.addArrangedSubview(input)
		}
		input?.supplementaryViews(for: views)
		
	}
	public func enableNextButton(title:String = "Next")
	{
		self.nextButton.isEnabled = true;
		self.nextButton.alpha = 1;
		
		self.nextButton.setTitle(title, for: .normal)
	}
	
	public func disableNextButton(title:String = "Next")
	{
		self.nextButton.isEnabled = false;
		self.nextButton.alpha = 0.5;
		self.nextButton.setTitle(title, for: .normal)
	}
	public func getValue() -> QuestionResponse? {
		return nil
	}
	
	public func setValue(_ value: QuestionResponse?) {
	
	}
	
	func build() {
		if root != nil {
			root.removeFromSuperview()
		}
		root = scroll { [weak self] in
			
			$0.stack {
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
					self?.promptLabel = $0.label {
						$0.text = "PromptThis is detailed content to further explain the prompt,This is detailed content to further explain the prompt,This is detailed content to further explain the prompt,This is detailed content to further explain the prompt,"
						Roboto.Style.heading($0)


					}
					self?.detailsLabel = $0.label {
						
						Roboto.Style.body($0)
						$0.text = "This is detailed content to further explain the prompt,This is detailed content to further explain the prompt,This is detailed content to further explain the prompt,This is detailed content to further explain the prompt,This is detailed content to further explain the prompt,This is detailed content to further explain the prompt,This is detailed content to further explain the prompt,This is detailed content to further explain the prompt,This is detailed content to further explain the prompt,"

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
					$0.text = "This is an error"

				}
				
				$0.view {
					$0.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .vertical)
				}
				//A container for miscelaneous views
				self?.views = $0.stack {
					$0.axis = .vertical
					$0.alignment = .center
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
						$0.setTitle("Next", for: .normal)
						
						$0.addAction { [weak self] in
							let value = self?.input?.getValue()
							
							self?.nextPressed?(self?.input, value)
						}
					}
				}
			}
		}
		root.layout { [weak self] in
			$0.top == safeAreaLayoutGuide.topAnchor ~ 999
			$0.trailing == safeAreaLayoutGuide.trailingAnchor ~ 999
			$0.bottom == safeAreaLayoutGuide.bottomAnchor ~ 999
			$0.leading == safeAreaLayoutGuide.leadingAnchor ~ 999
			$0.width == self!.widthAnchor ~ 999
			$0.height == self!.heightAnchor ~ 999
		}
		
		
		
	}
	
	// MARK: ScrollView
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.scrollIndicatorState(scrollView)
	}
	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		self.scrollIndicatorState(scrollView)
		
	}
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.scrollIndicatorState(scrollView)
		
	}
	private func scrollIndicatorState(_ scrollView: UIScrollView) {
		let contentHeight = scrollView.contentSize.height
		
		let viewHeight = scrollView.bounds.height
		let offset = scrollView.contentOffset.y
		
		let effectiveHeight = contentHeight - viewHeight - 20
		let maxProgress = contentHeight - viewHeight - effectiveHeight
		
		let progress = min(maxProgress, max(offset - effectiveHeight, 0))
		let convertedRect = nextButton.convert(nextButton.frame, to: scrollView)

		guard !scrollView.bounds.contains(convertedRect) && !scrollView.bounds.intersects(convertedRect) else {
			scrollIndicator.alpha = 0
			return
		}
		let alpha:CGFloat = 1.0 - (progress/maxProgress)
		scrollIndicator.alpha = alpha

	}
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
