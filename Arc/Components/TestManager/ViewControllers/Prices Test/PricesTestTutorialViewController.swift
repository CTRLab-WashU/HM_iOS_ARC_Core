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
	
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        self.duration = 43.5
        super.viewDidLoad()
		pricesTest.delegate = self
		pricesTest.autoStart = false
        pricesTest.isPracticeTest = true
		setupScript()
        if self.get(flag: .prices_tutorial_shown) == false {
            self.customView.firstTutorialRun()
        }
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
    override func finishTutorial() {
        self.set(flag: .prices_tutorial_shown)
        super.finishTutorial()
    }
	func didSelectPrice(_ option: Int) {
		view.window?.clearOverlay()
		currentHint?.removeFromSuperview()
		tutorialAnimation.resume()
		selectionMade = true
		pricesQuestions.questionDisplay.isUserInteractionEnabled = false
        getNextStep()

	}
	func didSelectGoodPrice(_ option: Int) {
		view.window?.clearOverlay()
		currentHint?.removeFromSuperview()
        selectionMade = true
		tutorialAnimation.resume()
        getNextStep()
	}
	func shouldEndTest() -> Bool {
		return false
	}
    
    func getNextStep() {
        guard state.conditions.count > 1 else { return }
        let condition = state.conditions[1]
        if state.conditions[0].flag == "prices_middle" || state.conditions[0].flag == "questions3-1" {
            return
        }
        if state.conditions[0].flag == "question3-2" ||
            condition.flag == "end" {
            self.finishTutorial()
            return
        }
        self.progress = CGFloat(condition.time)
        tutorialAnimation.time = condition.time * duration
        resumeTutorialanimation()
    }
	
	func setupScript() {
		state.addCondition(atTime: 0.0, flagName: "hide") { [weak self] in
			
			self?.pricesTest.priceDisplay.isHidden = true
		}
		
		state.addCondition(atTime: 0.02, flagName: "init") { [weak self] in
			self?.pricesTest.priceDisplay.isHidden = false
			
			self?.pricesTest.displayItem()
			self?.pricesTest.buildButtonStackView()
            self?.pricesTest.priceDisplay.isUserInteractionEnabled = false
		}
		
		state.addCondition(atTime: progress(seconds: 1), flagName: "overlay1") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.selectionMade = false

			weakSelf.pricesTest.priceDisplay.overlay()
			weakSelf.pricesTest.priceDisplay.isUserInteractionEnabled = true
			weakSelf.currentHint = self?.view.window?.hint {
				$0.content = "The Prices test has two parts. *First, evaluate the price.*"
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateHintStackMargins()
				$0.layout {
					$0.top == weakSelf.pricesTest.priceDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesTest.priceDisplay.centerXAnchor
					$0.width == weakSelf.pricesTest.priceDisplay.widthAnchor
				}
			}
		}
		
		state.addCondition(atTime: progress(seconds: 11), flagName: "overlay2") { [weak self] in
			guard let weakSelf = self else {
				return
			}
            guard weakSelf.selectionMade == false else {
                weakSelf.selectionMade = false
                return
            }
			weakSelf.currentHint?.removeFromSuperview()
			weakSelf.pricesTest.priceDisplay.isUserInteractionEnabled = true
			weakSelf.tutorialAnimation.pause()
			self?.currentHint = self?.view.window?.hint {
				$0.content = "*What do you think?*\n Choose the answer that makes sense to you."
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateHintStackMargins()
				$0.layout {
					$0.top == weakSelf.pricesTest.priceDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesTest.priceDisplay.centerXAnchor
					$0.width == weakSelf.pricesTest.priceDisplay.widthAnchor
				}
			}
		}
		
		state.addCondition(atTime: progress(seconds: 11.1), flagName: "overlay3") { [weak self] in
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
		
		state.addCondition(atTime: progress(seconds: 11.5), flagName: "question2-0") { [weak self] in
			
			self?.pricesTest.nextItem()
			self?.pricesTest.priceDisplay.isUserInteractionEnabled = true
			self?.selectionMade = false

			
		}
		
		state.addCondition(atTime: progress(seconds: 21.5), flagName: "question2-1") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			guard weakSelf.selectionMade == false else {
				weakSelf.selectionMade = false
				return
			}
			weakSelf.pricesTest.priceDisplay.isUserInteractionEnabled = true
            weakSelf.pricesTest.priceDisplay.overlay()
			weakSelf.tutorialAnimation.pause()
			self?.currentHint = self?.view.window?.hint {
				$0.content = "*What do you think?*\n Choose the answer that makes sense to you."
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateHintStackMargins()
				$0.layout {
					$0.top == weakSelf.pricesTest.priceDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesTest.priceDisplay.centerXAnchor
					$0.width == weakSelf.pricesTest.priceDisplay.widthAnchor
				}
			}
			
		}
		
		state.addCondition(atTime: progress(seconds: 22.5), flagName: "prices_middle") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.currentHint?.removeFromSuperview()
			weakSelf.pricesTest.priceDisplay.isUserInteractionEnabled = false
            weakSelf.view.window?.overlayView(withShapes: [])
            weakSelf.tutorialAnimation.pause()
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
					weakSelf.pricesQuestions.questionDisplay.isUserInteractionEnabled = true
                    weakSelf.selectionMade = false
				}
				$0.layout {
					$0.centerX == weakSelf.view.centerXAnchor
					$0.centerY == weakSelf.view.centerYAnchor
					$0.width == weakSelf.pricesTest.priceDisplay.widthAnchor
				}
			}
		}
		
		state.addCondition(atTime: progress(seconds: 32.5), flagName: "question3-0") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			guard weakSelf.selectionMade == false else {
				weakSelf.selectionMade = false
				return
			}

			weakSelf.currentHint?.removeFromSuperview()
            weakSelf.pricesQuestions.questionDisplay.isUserInteractionEnabled = true
            weakSelf.pricesQuestions.questionDisplay.overlay()
			weakSelf.tutorialAnimation.pause()

			self?.currentHint = self?.view.window?.hint {
				$0.content = "*What do you think?*\nTry your best to recall the price from part one."
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateHintStackMargins()
				$0.layout {
					$0.top == weakSelf.pricesQuestions.questionDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesQuestions.questionDisplay.centerXAnchor
					$0.width == weakSelf.pricesQuestions.questionDisplay.widthAnchor
				}
			}
		}
		
		state.addCondition(atTime: progress(seconds: 32.6), flagName: "questions3-1") { [weak self] in
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
                    weakSelf.selectionMade = false
                    weakSelf.pricesQuestions.topButton.set(selected: false)
                    weakSelf.pricesQuestions.bottomButton.set(selected: false)
				}
				$0.layout {
					$0.top == weakSelf.pricesQuestions.questionDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesQuestions.questionDisplay.centerXAnchor
					$0.width == weakSelf.pricesQuestions.questionDisplay.widthAnchor
				}
			}
		}
        
		state.addCondition(atTime: progress(seconds: 42.5), flagName: "question3-2") { [weak self] in
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
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateHintStackMargins()
				$0.layout {
					$0.top == weakSelf.pricesQuestions.questionDisplay.bottomAnchor + 10
					$0.centerX == weakSelf.pricesQuestions.questionDisplay.centerXAnchor
					$0.width == weakSelf.pricesQuestions.questionDisplay.widthAnchor
				}
			}
		}
        
		state.addCondition(atTime: progress(seconds: 43.5), flagName: "end") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			
			weakSelf.finishTutorial()
		}
		
	}
}
