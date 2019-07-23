//
//  PricesTestTutorialViewController.swift
//  Arc
//
//  Created by Philip Hayes on 7/3/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit

class PricesTestTutorialViewController: ACTutorialViewController, PricesTestDelegate {
	

	let pricesTest:PricesTestViewController = .get()
	var pricesQuestions:PricesQuestionViewController!
	var selectionMade = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		pricesTest.delegate = self
		pricesTest.autoStart = false
		setupScript()
		
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		addChild(pricesTest)
		customView.setContent(viewController: pricesTest)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		view.window?.clearOverlay()
		currentHint?.removeFromSuperview()

	}
	func didSelectPrice(_ option: Int) {
		view.window?.clearOverlay()
		currentHint?.removeFromSuperview()
		tutorialAnimation.resume()
		selectionMade = true
		pricesQuestions.questionDisplay.isUserInteractionEnabled = false

	}
	func didSelectGoodPrice(_ option: Int) {
		view.window?.clearOverlay()
		currentHint?.removeFromSuperview()
		tutorialAnimation.resume()
		selectionMade = true
	}
	func shouldEndTest() -> Bool {
		return false
	}
	
	func setupScript() {
		state.addCondition(atTime: 0.0, flagName: "hide") { [weak self] in
			
			self?.pricesTest.priceDisplay.isHidden = true
		}
		
		state.addCondition(atTime: 0.02, flagName: "init") { [weak self] in
			self?.pricesTest.priceDisplay.isHidden = false
			
			self?.pricesTest.displayItem()
			self?.pricesTest.buildButtonStackView()
		}
		
		state.addCondition(atTime: progress(seconds: 1), flagName: "overlay1") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.selectionMade = false

			weakSelf.pricesTest.priceDisplay.overlay()
			weakSelf.pricesTest.priceDisplay.isUserInteractionEnabled = false
			weakSelf.currentHint = self?.view.window?.hint {
				$0.content = "The Prices test has two parts. *First, evaluate the price.*"
				$0.layout {
					$0.top == weakSelf.pricesTest.priceDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesTest.priceDisplay.centerXAnchor
					$0.width == weakSelf.pricesTest.priceDisplay.widthAnchor
				}
			}
		}
		
		state.addCondition(atTime: progress(seconds: 3), flagName: "overlay2") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.currentHint?.removeFromSuperview()
			weakSelf.pricesTest.priceDisplay.isUserInteractionEnabled = true
			weakSelf.tutorialAnimation.pause()
			self?.currentHint = self?.view.window?.hint {
				$0.content = "*What do you think?*\n Choose the answer that makes sense to you."
				$0.layout {
					$0.top == weakSelf.pricesTest.priceDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesTest.priceDisplay.centerXAnchor
					$0.width == weakSelf.pricesTest.priceDisplay.widthAnchor
				}
			}
		}
		
		state.addCondition(atTime: progress(seconds: 3.1), flagName: "overlay3") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.currentHint?.removeFromSuperview()
			weakSelf.tutorialAnimation.pause()
			
			self?.currentHint = self?.view.window?.hint {
				$0.content = "*Great choice!*\nLet's try another."
				$0.buttonTitle = "Next"
				$0.button.addAction {
					weakSelf.tutorialAnimation.resume()
					weakSelf.view.window?.clearOverlay()
					weakSelf.currentHint?.removeFromSuperview()
					weakSelf.selectionMade = false

				}
				$0.layout {
					$0.top == weakSelf.pricesTest.priceDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesTest.priceDisplay.centerXAnchor
					$0.width == weakSelf.pricesTest.priceDisplay.widthAnchor
				}
			}
		}
		
		state.addCondition(atTime: progress(seconds: 3.5), flagName: "question2-0") { [weak self] in
			
			self?.pricesTest.nextItem()
			self?.pricesTest.priceDisplay.isUserInteractionEnabled = false
			self?.selectionMade = false

			
		}
		
		state.addCondition(atTime: progress(seconds: 5.0), flagName: "question2-1") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			guard weakSelf.selectionMade == false else {
				weakSelf.selectionMade = false
				
				return
				
			}
			weakSelf.pricesTest.priceDisplay.isUserInteractionEnabled = true

			weakSelf.tutorialAnimation.pause()
			self?.currentHint = self?.view.window?.hint {
				$0.content = "*What do you think?*\n Choose the answer that makes sense to you."
				$0.layout {
					$0.top == weakSelf.pricesTest.priceDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesTest.priceDisplay.centerXAnchor
					$0.width == weakSelf.pricesTest.priceDisplay.widthAnchor
				}
			}
			
		}
		
		state.addCondition(atTime: progress(seconds: 6), flagName: "question2-2") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.currentHint?.removeFromSuperview()
			weakSelf.tutorialAnimation.pause()
			weakSelf.pricesTest.priceDisplay.isUserInteractionEnabled = false
			self?.currentHint = self?.view.window?.hint {
				$0.content = "*Another great choice!*\nLet's proceed to part two."
				$0.buttonTitle = "Next"
				$0.button.addAction {
					weakSelf.tutorialAnimation.resume()
					weakSelf.view.window?.clearOverlay()
					weakSelf.currentHint?.removeFromSuperview()
					weakSelf.pricesQuestions = weakSelf.pricesTest.preparedQuestionController()
					weakSelf.pricesQuestions.shouldAutoProceed = false
					weakSelf.pricesQuestions.delegate = self
					weakSelf.customView.setContent(viewController: weakSelf.pricesQuestions)
					weakSelf.pricesQuestions.buildButtonStackView()
					weakSelf.pricesQuestions.prepareQuestions()
					weakSelf.pricesQuestions.selectQuestion()
					weakSelf.pricesQuestions.questionDisplay.isUserInteractionEnabled = false
				}
				$0.layout {
					$0.centerX == weakSelf.view.centerXAnchor
					$0.centerY == weakSelf.view.centerYAnchor
					$0.width == weakSelf.pricesTest.priceDisplay.widthAnchor
				}
			}
		}
		
		state.addCondition(atTime: progress(seconds: 7), flagName: "question3-0") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			guard weakSelf.selectionMade == false else {
				weakSelf.selectionMade = false

				return
				
			}

			weakSelf.currentHint?.removeFromSuperview()
			weakSelf.tutorialAnimation.pause()
			weakSelf.pricesQuestions.questionDisplay.isUserInteractionEnabled = true
			weakSelf.pricesQuestions.questionDisplay.overlay()

			self?.currentHint = self?.view.window?.hint {
				$0.content = "*What do you think?*\nTry your best to recall the price from part one."
				
				$0.layout {
					$0.top == weakSelf.pricesQuestions.questionDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesQuestions.questionDisplay.centerXAnchor
					$0.width == weakSelf.pricesQuestions.questionDisplay.widthAnchor
				}
			}
		}
		
		state.addCondition(atTime: progress(seconds: 7.1), flagName: "questions3-1") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.currentHint?.removeFromSuperview()
			weakSelf.tutorialAnimation.pause()
			
			self?.currentHint = self?.view.window?.hint {
				$0.content = "*Great choice!*\nLet's try another."
				$0.buttonTitle = "Next"
				$0.button.addAction {
					weakSelf.tutorialAnimation.resume()
					weakSelf.view.window?.clearOverlay()
					weakSelf.currentHint?.removeFromSuperview()
					weakSelf.pricesQuestions.selectQuestion()
					weakSelf.pricesQuestions.questionDisplay.isUserInteractionEnabled = true

				}
				$0.layout {
					$0.top == weakSelf.pricesQuestions.questionDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesQuestions.questionDisplay.centerXAnchor
					$0.width == weakSelf.pricesQuestions.questionDisplay.widthAnchor
				}
			}
		}
		state.addCondition(atTime: progress(seconds: 9), flagName: "question3-2") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			guard weakSelf.selectionMade == false else {
				weakSelf.selectionMade = false
				
				return
				
			}
			weakSelf.currentHint?.removeFromSuperview()
			weakSelf.tutorialAnimation.pause()
			weakSelf.pricesQuestions.questionDisplay.isUserInteractionEnabled = true
			weakSelf.pricesQuestions.questionDisplay.overlay()
			
			self?.currentHint = self?.view.window?.hint {
				$0.content = "*What do you think?*\nTry your best to recall the price from part one."
				
				$0.layout {
					$0.top == weakSelf.pricesQuestions.questionDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesQuestions.questionDisplay.centerXAnchor
					$0.width == weakSelf.pricesQuestions.questionDisplay.widthAnchor
				}
			}
		}
		state.addCondition(atTime: progress(seconds: 10), flagName: "end") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			
			weakSelf.finishTutorial()
		}
		
		
	}
}
