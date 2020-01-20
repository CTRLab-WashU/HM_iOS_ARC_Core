//
//  SimplifiedPricesTestTutorialViewController.swift
//  Arc
//
//  Created by Matt Gannon on 11/12/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit

class SimplifiedPricesTestTutorialViewController: PricesTestTutorialViewController {

    override func viewDidLoad() {
        self.duration = 18.5
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    override func setupScript() {
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
            
            let shape = OverlayShape.roundedRect(weakSelf.pricesTest.priceDisplay, 8, CGSize(width: -8, height: -8))
            weakSelf.pricesTest.view.overlayView(withShapes: [shape])
            weakSelf.pricesTest.priceDisplay.isUserInteractionEnabled = true
            weakSelf.currentHint = self?.view.window?.hint {
                $0.content = "*Memorize the displayed items and their prices.* You will have 3 seconds per item."
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()
                $0.layout {
                    $0.top == weakSelf.pricesTest.priceDisplay.bottomAnchor + 10
                    $0.centerX == weakSelf.pricesTest.priceDisplay.centerXAnchor
                    $0.width == weakSelf.pricesTest.priceDisplay.widthAnchor
                }
            }
        }

        state.addCondition(atTime: progress(seconds: 4), flagName: "question2-0") { [weak self] in
            self?.currentHint?.removeFromSuperview()
            self?.view.clearOverlay()
            self?.progress = 0.25
            self?.pricesTest.nextItem()
            self?.pricesTest.priceDisplay.isUserInteractionEnabled = true
            self?.selectionMade = false
            
            
        }
        
        state.addCondition(atTime: progress(seconds: 7), flagName: "prices_middle") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.currentHint?.removeFromSuperview()
            weakSelf.pricesTest.priceDisplay.isUserInteractionEnabled = false
            weakSelf.pricesTest.view.overlayView(withShapes: [])
            weakSelf.tutorialAnimation.pause()
            weakSelf.progress = 0.5
            self?.currentHint = self?.view.window?.hint {
                $0.content = "*Great!*\nLet's proceed to part two."
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
                    $0.width == 232
                }
            }
        }
        
        state.addCondition(atTime: progress(seconds: 7.1), flagName: "question3-0") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            guard weakSelf.selectionMade == false else {
                weakSelf.selectionMade = false
                return
            }
            
            weakSelf.currentHint?.removeFromSuperview()
            weakSelf.pricesQuestions.questionDisplay.isUserInteractionEnabled = true
            let shape = OverlayShape.roundedRect(weakSelf.pricesQuestions.questionDisplay, 8, CGSize(width: -8,height:-8))
            weakSelf.pricesQuestions.view.overlayView(withShapes: [shape])
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
                $0.updateTitleStackMargins()
                $0.layout {
                    $0.top == weakSelf.pricesQuestions.questionDisplay.bottomAnchor + 10
                    $0.centerX == weakSelf.pricesQuestions.questionDisplay.centerXAnchor
                    $0.width == weakSelf.pricesQuestions.questionDisplay.widthAnchor
                }
            }
        }
        
        state.addCondition(atTime: progress(seconds: 7.2), flagName: "questions3-1") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.currentHint?.removeFromSuperview()
            weakSelf.tutorialAnimation.pause()
            weakSelf.progress = 0.75
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
                    $0.width == 232
                }
            }
        }
        
        state.addCondition(atTime: progress(seconds: 17.5), flagName: "question3-2") { [weak self] in
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
            let shape = OverlayShape.roundedRect(weakSelf.pricesQuestions.questionDisplay, 8, CGSize(width: -8, height: -8))
            weakSelf.pricesQuestions.view.overlayView(withShapes: [shape])
            
            
            self?.currentHint = self?.view.window?.hint {
                $0.content = "*What do you think?*\nTry your best to recall the price from part one."
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()
                $0.layout {
                    $0.top == weakSelf.pricesQuestions.questionDisplay.bottomAnchor + 10
                    $0.centerX == weakSelf.pricesQuestions.questionDisplay.centerXAnchor
                    $0.width == weakSelf.pricesQuestions.questionDisplay.widthAnchor
                }
            }
        }
        
        state.addCondition(atTime: progress(seconds: 18.5), flagName: "end") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.finishTutorial()
        }
        
    }

}