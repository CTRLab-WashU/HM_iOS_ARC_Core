//
//  GridTestTutorialViewController.swift
//  Arc
//
//  Created by Philip Hayes on 7/19/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
class ExtendedGridTestTutorialViewController: ACTutorialViewController, ExtendedGridTestViewControllerDelegate {
	
	enum TestPhase {
		case start, fs, fsTimed, recallFirstStep, recallFirstChoiceMade, recallSecondChoiceMade, showingReminder, recall, end
	}
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
	
	let test:ExtendedGridTestViewController = .get()
	
	var selectionMade = false
    var showingSelectNextTwo = false
	var lockIncorrect = false
	var maxGridSelected = 3
	var gridSelected = 0
	var phase:TestPhase = .start
    var indicator:IndicatorView?
    var gridChoice:GridChoiceView?
    
    override func viewDidLoad() {
		duration = 25
        super.viewDidLoad()
        test.isPracticeTest = true
		test.shouldAutoProceed = false
		test.delegate = self
		setupScript()
		addChild(test)
		customView.setContent(viewController: test)
		test.tapOnTheFsLabel.isHidden = true
        // Do any additional setup after loading the view.
		//If these flags are set then we don't have to hide the xbutton
		
        if self.get(flag: .grids_tutorial_shown) == false  {
			if Arc.get(flag: .tutorial_optional) {
				self.set(flag: .grids_tutorial_shown)
			}

            self.customView.firstTutorialRun()
        }
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		test.view.clearOverlay()
		view.removeHighlight()
		currentHint?.removeFromSuperview()
		
	}
    override func finishTutorial() {
        self.set(flag: .grids_tutorial_shown)
        super.finishTutorial()
    }
	func didSelect(){
		
		
        if showingSelectNextTwo == false {
            currentHint?.removeFromSuperview()
        }
		switch phase {
		
		
		case .start:
			test.view.clearOverlay()
			view.removeHighlight()
			tutorialAnimation.resume()

			break
            
        case .fs:
            test.view.clearOverlay()
            view.removeHighlight()
            tutorialAnimation.resume()

            test.collectionView.isUserInteractionEnabled = false
        
        case .fsTimed:
            test.view.clearOverlay()
            view.removeHighlight()
            test.collectionView.isUserInteractionEnabled = true
        
		case .recallFirstStep:
			test.view.clearOverlay()
            
			view.removeHighlight()
			removeHint(hint: "hint")
			//tutorialAnimation.time = 11.5
			//addFirstHint(hint: "hint")
			tutorialAnimation.resume()

		case .recallFirstChoiceMade, .recallSecondChoiceMade:
            if showingSelectNextTwo == false {
                test.view.clearOverlay()
                removeHint(hint: "hint")
            }
            //showingSelectNextTwo = true
            view.removeHighlight()
			//tutorialAnimation.time = 10
			//needHelp()
			tutorialAnimation.resume()


		case .recall:
			test.view.clearOverlay()
			view.removeHighlight()
			removeHint(hint: "hint")

			needHelp()

			tutorialAnimation.resume()
			
		case .end:
			test.view.clearOverlay()
			view.removeHighlight()
			removeHint(hint: "hint")

			//tutorialAnimation.time = 24.5
			tutorialAnimation.resume()
			break
		case .showingReminder:
			removeHint(hint: "hint")

		}
		
		selectionMade = true
	}
	//MARK:-Delegate
	func didSelectGrid(indexPath: IndexPath) {
		//gridSelected += 1
		
        //hideImages()
		switch gridSelected  {
		case 1:
            //maybeShowSelectNextTwoHint()
			phase = .recallFirstChoiceMade
		case 2:
			phase = .recallSecondChoiceMade
		case 3:
            //removeFinalHint()
			test.collectionView.isUserInteractionEnabled = false
			phase = .end
		default:
			phase = .recallFirstStep
		}
		
		didSelect()
	}
	
	func didSelectLetter(indexPath: IndexPath) {
			didSelect()
	}
	
	func didDeselectLetter(indexPath: IndexPath) {
		didSelect()
	}
    
    func didUpdateIndicator(indexPath: IndexPath, indicator: IndicatorView?) {
        self.gridChoice = indicator as? GridChoiceView
        if self.gridChoice != nil {
            self.test.collectionView.removeHighlight()
        }
        self.tutorialAnimation.resume()
        currentHint?.removeFromSuperview()
        
    }

//    func hideImages() {
//        for indexPath in self.test.symbolIndexPaths {
//            guard let cell = self.test.collectionView.cellForItem(at: indexPath) as? GridImageCell else { return }
//            cell.image.isHidden = true
//        }
//    }

	func setupScript() {
		state.addCondition(atTime: progress(seconds: 0), flagName: "start-0") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.buildStartScreen(message: "In this three part test, you’ll be asked to *recall the location* of these items.".localized(ACTranslationKey.popup_tutorial_grid_recall),
									  buttonTitle: "Got it".localized(ACTranslationKey.popup_gotit))
			
		}
		state.addCondition(atTime: progress(seconds: 0), flagName: "start-1") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.tutorialAnimation.pause()
			weakSelf.test.displaySymbols()
			weakSelf.test.view.overlayView(withShapes: [])
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = "The items will be placed in a grid of boxes. *Remember which box each item is in.* You will have 3 seconds.".localized(ACTranslationKey.popup_tutorial_rememberbox)
				$0.buttonTitle = "I'm Ready".localized(ACTranslationKey.popup_tutorial_ready)
				$0.onTap = { [weak self] in
					
					weakSelf.phase = .start
					self?.didSelect()
				}
				
				$0.layout {
					$0.centerY == weakSelf.view.centerYAnchor - 20
					$0.centerX == weakSelf.view.centerXAnchor

					$0.width == weakSelf.test.collectionView.widthAnchor - 90
					
				}
			}
			
		}
		state.addCondition(atTime: progress(seconds: 3), flagName: "start-2") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.progress = 0.25
			weakSelf.tutorialAnimation.pause()
			weakSelf.test.displaySymbols()
			weakSelf.test.view.overlayView(withShapes: [])
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = "*Great!*\nLet's proceed to part two.".localized(ACTranslationKey.popup_tutorial_part2)
				$0.buttonTitle = "NEXT".localized(ACTranslationKey.button_next)
				$0.onTap = { [weak self] in
					self?.didSelect()
				}
				
				$0.layout {
					$0.centerY == weakSelf.view.centerYAnchor
					$0.centerX == weakSelf.view.centerXAnchor
					
					$0.width == weakSelf.test.collectionView.widthAnchor - 75
					
				}
			}
			
		}
		
		state.addCondition(atTime: progress(seconds: 3), flagName: "fs-0") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.test.displayFs()
			weakSelf.test.collectionView.isUserInteractionEnabled = true

			
			
		}
		state.addCondition(atTime: progress(seconds: 3.5), flagName: "fs-2") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.tutorialAnimation.pause()
			weakSelf.phase = .fs
			let index = weakSelf.test.fIndexPaths[3]
			guard let cell = weakSelf.test.overlayCell(at: index) else {
				return
			}

			weakSelf.test.collectionView.isUserInteractionEnabled = true

			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = "Tap this letter F.".localized(ACTranslationKey.popup_tutorial_tapf1)
				$0.targetView = cell
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()
				$0.layout {
					$0.top >= weakSelf.view.safeAreaLayoutGuide.topAnchor + 24
					$0.leading >= weakSelf.view.safeAreaLayoutGuide.leadingAnchor + 24
					$0.trailing <= weakSelf.view.safeAreaLayoutGuide.trailingAnchor - 24
					$0.bottom <= weakSelf.view.safeAreaLayoutGuide.bottomAnchor - 24
					
					$0.centerY == cell.centerYAnchor + 80 ~ 500
					$0.centerX == cell.centerXAnchor ~ 500
					
					
					
				}
			}
			
		}
		state.addCondition(atTime: progress(seconds: 3.5), flagName: "fs-3") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.progress = 0.5
			weakSelf.tutorialAnimation.pause()
			weakSelf.test.view.overlayView(withShapes: [])
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = "*Perfect!*\nNow: *Tap all the F’s* you see as quickly as you can.\nYou will have 8 seconds.".localized(ACTranslationKey.popup_tutorial_tapf2)
				$0.buttonTitle = "I'm Ready".localized(ACTranslationKey.popup_tutorial_ready)
				$0.onTap = { [weak self] in
					self?.didSelect()
					weakSelf.phase = .fsTimed
					weakSelf.test.collectionView.isUserInteractionEnabled = true
				}
				
				$0.layout {
					$0.centerY == weakSelf.view.centerYAnchor
					$0.centerX == weakSelf.view.centerXAnchor
					
					$0.width == weakSelf.test.collectionView.widthAnchor - 75
					
				}
			}
			
		}
		
		state.addCondition(atTime: progress(seconds: 11.5), flagName: "fs-4") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.progress = 0.75
			weakSelf.tutorialAnimation.pause()
			weakSelf.test.view.overlayView(withShapes: [])
			weakSelf.test.collectionView.isUserInteractionEnabled = false
			weakSelf.phase = .fs
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = "*Nice work!*\nDon't worry if you didn't find them all.".localized(ACTranslationKey.popup_tutorial_tapf3)
				$0.buttonTitle = "NEXT".localized(ACTranslationKey.button_next)
				$0.onTap = {
					weakSelf.phase = .recallFirstStep
					weakSelf.didSelect()
					weakSelf.test.clearGrids()
					weakSelf.buildStartScreen(message: "In the final part of the test, you will select the three boxes where these items were located in part one.".localized(ACTranslationKey.popup_tutorial_selectbox),
											  buttonTitle: "I'm Ready".localized(ACTranslationKey.popup_tutorial_ready))
                    weakSelf.test.displayGrid()
				}
				
				$0.layout {
					$0.centerY == weakSelf.view.centerYAnchor
					$0.centerX == weakSelf.view.centerXAnchor
					
					$0.width == weakSelf.test.collectionView.widthAnchor - 75
					
				}
			}
			
		}
		
		state.addCondition(atTime: progress(seconds: 14.5), flagName: "symbols-0") { [weak self] in
			guard let weakSelf = self else {
				return
			}
            

            weakSelf.tutorialAnimation.pause()
			weakSelf.test.collectionView.isUserInteractionEnabled = true
            //weakSelf.addFirstHint(hint: "hint")
			
            let index = weakSelf.test.symbolIndexPaths[0]
            guard let cell = weakSelf.test.overlayCell(at: index) else {
                return
            }
            cell.backgroundColor = UIColor(named: "Secondary")
            weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                *Hint:* The cell phone was located here. Tap this box.
                """.localized(ACTranslationKey.popup_tutorial_cellbox)
                $0.targetView = cell
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()
                
                $0.layout {
                    $0.centerX == weakSelf.view.centerXAnchor
                    $0.width == 252
                    
                    if index.row/5 > 2 {
                        //If above
                        $0.bottom == cell.topAnchor + 40
                    } else {
                        $0.top == cell.bottomAnchor + 20
                    }
                }
            }
		}
        //Grid Cell Selected - Select Phone Button
        
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-1") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
            let width = weakSelf.test.collectionStack.bounds.height - weakSelf.test.collectionViewHeight.constant
            var height = weakSelf.test.collectionStack.bounds.width - weakSelf.test.collectionViewWidth.constant
            if weakSelf.test.collectionViewHeight.constant >= 400 {
                height += 50
            }
            //Darken Area around Indicator and top of cell
            weakSelf.view.overlayView(withShapes: [.roundedRect(weakSelf.test.collectionView, 8, CGSize(width: width, height: height))])
            
            weakSelf.gridChoice?.phoneButton.addAction { [weak self] in
                self?.tutorialAnimation.resume()
                weakSelf.view.clearOverlay()
            }
            weakSelf.gridChoice?.keyButton.isEnabled = false
            weakSelf.gridChoice?.penButton.isEnabled = false
            weakSelf.test.collectionView.isUserInteractionEnabled = false
            //Overlay Phone Button
            weakSelf.gridChoice?.phoneButton.highlight()
            let index = weakSelf.test.symbolIndexPaths[0]
            //Show Hint for Tap Phone Button
            weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                Now, tap the cell phone to place it in the selected box.
                """.localized(ACTranslationKey.popup_tutorial_tapsymbol)
                $0.targetView = weakSelf.gridChoice
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: false,
                                                        arrowAbove: false))
                
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()

                $0.layout {
                    $0.centerX == weakSelf.view.centerXAnchor
                    $0.width == 252

                    if index.row/5 > 2 {
                        //If above
                        $0.bottom == weakSelf.gridChoice!.topAnchor + 20
                    } else {
                        $0.top == weakSelf.gridChoice!.bottomAnchor + 50
                    }
                }
            }
        }
        
         //Show Hint for Moving Phone
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-2") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
             weakSelf.test.collectionView.isUserInteractionEnabled = false
             weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                    Great! If you change your mind, you can move the item. Let's try it.
                    """.localized(ACTranslationKey.popup_tutorial_great)
                $0.buttonTitle = "Okay".localized(ACTranslationKey.button_okay)
                $0.onTap = {
                    weakSelf.removeFinalHint()
                    weakSelf.view.clearOverlay()
                    weakSelf.didSelect()
                }
                $0.targetView = weakSelf.gridChoice
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: false,
                                                        arrowAbove: false))
                
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()

                $0.layout {
                    $0.centerX == weakSelf.view.centerXAnchor
                    $0.width == 252
                    $0.bottom == weakSelf.view.bottomAnchor - 40
                }
            }
        }
    
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-3") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
            weakSelf.test.collectionView.isUserInteractionEnabled = true
            let index = IndexPath(row: 8, section: 0)
            //Overlay New Cell
            guard let cell = weakSelf.test.overlayCell(at: index) else {
                return
            }
            //Tap New Cell
             weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                    First, tap a different box.
                    """.localized(ACTranslationKey.popup_tutorial_tapbox4)
                $0.targetView = cell
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()

                $0.layout {
                    $0.centerX == weakSelf.view.centerXAnchor
                    $0.width == 252

                    if index.row/5 > 2 {
                        //If above
                        $0.bottom == cell.topAnchor + 40
                    } else {
                        $0.top == cell.bottomAnchor + 30
                    }
                }
            }
        }
        
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-4") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
            weakSelf.test.collectionView.isUserInteractionEnabled = false
            let index = IndexPath(row: 8, section: 0)
            let width = weakSelf.test.collectionStack.bounds.height - weakSelf.test.collectionViewHeight.constant
            var height = weakSelf.test.collectionStack.bounds.width - weakSelf.test.collectionViewWidth.constant
            if weakSelf.test.collectionViewHeight.constant >= 400 {
                height += 50
            }
            
            //Overlay New Cell
            weakSelf.view.overlayView(withShapes: [.roundedRect(weakSelf.test.collectionView, 8, CGSize(width: width, height: height))])
            weakSelf.gridChoice?.phoneButton.addAction { [weak self] in
                self?.tutorialAnimation.resume()
            }
            weakSelf.gridChoice?.keyButton.isEnabled = false
            weakSelf.gridChoice?.penButton.isEnabled = false
            weakSelf.gridChoice?.phoneButton.highlight()
            //Tap New Cell
             weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                    Then, tap the cell phone button to place it in the new box.
                    """.localized(ACTranslationKey.popup_tutorial_tapsymbol2)
                $0.targetView = weakSelf.gridChoice
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: false,
                                                        arrowAbove: false))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()

                $0.layout {
                    $0.centerX == weakSelf.view.centerXAnchor
                    $0.width == 252
                    $0.height == 100
                    if index.row/5 > 2 {
                    //If above
                    $0.bottom == weakSelf.gridChoice!.topAnchor + 20
                    } else {
                        $0.top == weakSelf.gridChoice!.bottomAnchor + 50
                    }
                }
            }
        }
        
        //Overlay Recent Cell and Show Remove Item Hint
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-5") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
            weakSelf.view.clearOverlay()
            weakSelf.test.collectionView.isUserInteractionEnabled = true
            let index = IndexPath(row: 8, section: 0)
            //Overlay Recent Cell
            guard let cell = weakSelf.test.overlayCell(at: index) else {
                return
            }
            
            //Tap Recent Cell
             weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                    Great! If you would like to clear a box with an item, tap the box and select the *Remove Item* button.
                    """.localized(ACTranslationKey.popup_tutorial_great_remove)
                $0.targetView = cell
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()

                $0.layout {
                    $0.centerX == weakSelf.view.centerXAnchor
                    $0.width == 252
                    $0.height == 134
                    if index.row/5 > 2 {
                        //If above
                        $0.bottom == cell.topAnchor + 40
                    } else {
                        $0.top == cell.bottomAnchor + 30
                    }
                }
            }
        }
            
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-6") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
            weakSelf.view.removeHighlight()
            weakSelf.test.collectionView.isUserInteractionEnabled = false
            weakSelf.gridChoice?.keyButton.isEnabled = false
            weakSelf.gridChoice?.penButton.isEnabled = false

            let removeButton = weakSelf.gridChoice?.removeButton
            removeButton?.addAction {
                self?.tutorialAnimation.resume()
                weakSelf.view.clearOverlay()
            }
            //Highlight Remove Item button
            weakSelf.view.overlayView(withShapes: [.roundedRect((weakSelf.gridChoice?.removeButton)!, 8, CGSize(width: 8-(weakSelf.gridChoice?.removeButton.bounds.width)!, height: 12-(weakSelf.gridChoice?.removeButton.bounds.height)!))])
            
            //Tap Remove Button
            //Show Remove Item hint
             weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                    Tap Remove Item button
                    """.localized(ACTranslationKey.popup_tutorial_remove)
                $0.targetView = weakSelf.gridChoice?.removeButton
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()

                $0.layout {
                    $0.centerX == weakSelf.gridChoice!.centerXAnchor
                    $0.width == 252
                    $0.top == weakSelf.gridChoice!.bottomAnchor + 15

                }
            }
        }
            
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-7") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            //weakSelf.tutorialAnimation.pause()
            //weakSelf.view.clearOverlay()
            
            let index = weakSelf.test.symbolIndexPaths[0]
            
            weakSelf.test.collectionView.isUserInteractionEnabled = false
            
            if let c = weakSelf.test.collectionView.cellForItem(at: index) as? GridImageCell {
                c.isSelected = true
                weakSelf.test.collectionView(weakSelf.test.collectionView, didSelectItemAt: index)
            } else {
                return
            }
            //weakSelf.tutorialAnimation.pause()
            let width = weakSelf.test.collectionStack.bounds.height - weakSelf.test.collectionViewHeight.constant
            var height = weakSelf.test.collectionStack.bounds.width - weakSelf.test.collectionViewWidth.constant
            if weakSelf.test.collectionViewHeight.constant >= 400 {
                height += 50
            }
            weakSelf.view.overlayView(withShapes: [.roundedRect(weakSelf.test.collectionView, 8, CGSize(width: width, height: height))])
            
             weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                    Great! Let's place the cell phone back in the first box.
                    """.localized(ACTranslationKey.popup_tutorial_tapsymbol3)
                $0.targetView = weakSelf.gridChoice?.removeButton
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: false,
                                                        arrowAbove: false))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()

                $0.layout {
                    $0.centerX == weakSelf.view.centerXAnchor
                    $0.width == 252
                    $0.top == weakSelf.gridChoice!.bottomAnchor + 50

                }
            }
        }
        
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-8") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
            weakSelf.gridChoice?.keyButton.isEnabled = false
            weakSelf.gridChoice?.penButton.isEnabled = false
            weakSelf.gridChoice?.phoneButton.highlight()
            weakSelf.gridChoice?.phoneButton.addAction { [weak self] in
                self?.tutorialAnimation.resume()
                weakSelf.view.clearOverlay()
            }
        }
        
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-9") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            //weakSelf.tutorialAnimation.pause()
            weakSelf.view.clearOverlay()
            
            weakSelf.test.collectionView.isUserInteractionEnabled = true
            weakSelf.removeFinalHint()
             weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                    Now, place the other two items on the grid.
                    """.localized(ACTranslationKey.popup_tutorial_tapbox)
                //$0.targetView = weakSelf.gridChoice?.removeButton
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: false,
                                                        arrowAbove: false))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()

                $0.layout {
                    $0.centerX == weakSelf.view.centerXAnchor
                    
                    $0.width == 252
                    $0.bottom == weakSelf.view.bottomAnchor - 30

                }
            }
        }
        
        state.addCondition(atTime: progress(seconds:19.5), flagName: "symbols-10") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.removeFinalHint()
            weakSelf.checkGridSelected()
            if weakSelf.gridSelected < 2 {
                weakSelf.tutorialAnimation.pause()
                weakSelf.test.collectionView.isUserInteractionEnabled = true
            
                 weakSelf.currentHint = weakSelf.view.window?.hint {
                    $0.content = """
                        Need help?
                        """.localized(ACTranslationKey.popup_tutorial_needhelp)
                    $0.buttonTitle = "Remind Me".localized(ACTranslationKey.popup_tutorial_remindme)
                    //$0.targetView = weakSelf.gridChoice?.removeButton
                    $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                            secondaryColor: UIColor(named:"HintFill")!,
                                                            textColor: .black,
                                                            cornerRadius: 8.0,
                                                            arrowEnabled: false,
                                                            arrowAbove: false))
                    $0.onTap = {
                        weakSelf.removeFinalHint()
                        weakSelf.tutorialAnimation.resume()
                    }
                    $0.updateHintContainerMargins()
                    $0.updateTitleStackMargins()

                    $0.layout {
                        $0.centerX == weakSelf.view.centerXAnchor
                        
                        $0.width == 252
                        $0.bottom == weakSelf.view.bottomAnchor - 30

                    }
                }
            } else {
                weakSelf.tutorialAnimation.time = 24.5
                weakSelf.tutorialAnimation.resume()
            }
        }
        
        state.addCondition(atTime: progress(seconds:19.5), flagName: "symbols-11") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.checkGridSelected()
            if weakSelf.gridSelected < 2 {
                weakSelf.tutorialAnimation.pause()
                weakSelf.view.clearOverlay()
                weakSelf.test.collectionView.isUserInteractionEnabled = true
                var index = weakSelf.test.symbolIndexPaths
                index.removeFirst()
                
                weakSelf.test.overlayCells(at: index)
            }
        }
        
        state.addCondition(atTime: progress(seconds:19.5), flagName: "symbols-12") { [weak self] in
            guard let weakSelf = self else {
                return
            }
                weakSelf.checkGridSelected()
                if weakSelf.gridSelected < 2 {
                    weakSelf.tutorialAnimation.pause()
                    weakSelf.test.collectionView.isUserInteractionEnabled = false
                    weakSelf.gridChoice?.phoneButton.addAction { [weak self] in
                        weakSelf.test.collectionView.isUserInteractionEnabled = true
                        self?.tutorialAnimation.resume()
                    }
                    weakSelf.gridChoice?.penButton.addAction { [weak self] in
                        weakSelf.test.collectionView.isUserInteractionEnabled = true
                        self?.tutorialAnimation.resume()
                    }
                    weakSelf.gridChoice?.keyButton.addAction { [weak self] in
                        weakSelf.test.collectionView.isUserInteractionEnabled = true
                        self?.tutorialAnimation.resume()
                    }
                }
            }
        
        state.addCondition(atTime: progress(seconds:24.5), flagName: "symbols-13") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.checkGridSelected()
            if weakSelf.gridSelected < 3 {
                weakSelf.tutorialAnimation.pause()
                weakSelf.test.collectionView.isUserInteractionEnabled = true
            
                 weakSelf.currentHint = weakSelf.view.window?.hint {
                    $0.content = """
                        Need help?
                        """.localized(ACTranslationKey.popup_tutorial_needhelp)
                    $0.buttonTitle = "Remind Me".localized(ACTranslationKey.popup_tutorial_remindme)
                    //$0.targetView = weakSelf.gridChoice?.removeButton
                    $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                            secondaryColor: UIColor(named:"HintFill")!,
                                                            textColor: .black,
                                                            cornerRadius: 8.0,
                                                            arrowEnabled: false,
                                                            arrowAbove: false))
                    $0.onTap = {
                        weakSelf.removeFinalHint()
                        weakSelf.tutorialAnimation.resume()
                    }
                    $0.updateHintContainerMargins()
                    $0.updateTitleStackMargins()

                    $0.layout {
                        $0.centerX == weakSelf.view.centerXAnchor
                        
                        $0.width == 252
                        $0.bottom == weakSelf.view.bottomAnchor - 30

                    }
                }
            } else {
                weakSelf.tutorialAnimation.time = 25
                weakSelf.tutorialAnimation.resume()
            }
        }
        
        state.addCondition(atTime: progress(seconds:24.5), flagName: "symbols-14") { [weak self] in
            guard let weakSelf = self else {
                return
            }
           weakSelf.checkGridSelected()
           if weakSelf.gridSelected < 3 {
                weakSelf.tutorialAnimation.pause()
                weakSelf.view.clearOverlay()
                weakSelf.test.collectionView.isUserInteractionEnabled = true
                let keyCell = weakSelf.test.symbolIndexPaths[1]
                let penCell = weakSelf.test.symbolIndexPaths[2]
                if let value = weakSelf.test.controller.get(selectedData: penCell.row, id: weakSelf.test.responseId, questionIndex: weakSelf.test.testNumber, gridType: .image)?.selection, value > -1 {
                    guard let _ = weakSelf.test.overlayCell(at: keyCell) else {
                        return
                    }
                } else {
                    guard let _ = weakSelf.test.overlayCell(at: penCell) else {
                        return
                    }
                }
            }
        }
        
        state.addCondition(atTime: progress(seconds:24.5), flagName: "symbols-15") { [weak self] in
            guard let weakSelf = self else {
                return
            }
                weakSelf.checkGridSelected()
                if weakSelf.gridSelected < 3 {
                    weakSelf.tutorialAnimation.pause()
                    weakSelf.test.collectionView.isUserInteractionEnabled = false
                    weakSelf.gridChoice?.phoneButton.addAction { [weak self] in
                        self?.tutorialAnimation.resume()
                    }
                    weakSelf.gridChoice?.penButton.addAction { [weak self] in
                        self?.tutorialAnimation.resume()
                    }
                    weakSelf.gridChoice?.keyButton.addAction { [weak self] in
                        self?.tutorialAnimation.resume()
                    }
                }
            }
        //Other Two Grids Items Hint
        //Need Help
		state.addCondition(atTime: progress(seconds: 25), flagName: "end") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.finishTutorial()
		}
	}
	func buildStartScreen(message:String, buttonTitle:String) {
		tutorialAnimation.pause()
		let view = customView.containerView.view {
			$0.backgroundColor = .white
			$0.layout {
				$0.top == customView.containerView.topAnchor ~ 998
				$0.leading == customView.containerView.leadingAnchor ~ 998
				$0.trailing == customView.containerView.trailingAnchor ~ 998
				$0.bottom == customView.containerView.bottomAnchor ~ 998
			}
		}
		var image:UIImageView!
		let _ = view.stack {
			$0.translatesAutoresizingMaskIntoConstraints = false
			$0.distribution = .fillEqually
			$0.axis = .horizontal
			$0.spacing = 20
			
			
			$0.image {
				$0.image = #imageLiteral(resourceName: "phone")
			}
			image = $0.image {
				$0.image = #imageLiteral(resourceName: "key")
			}
			$0.image {
				$0.image = #imageLiteral(resourceName: "pen")
			}
			$0.layout {
				
				$0.centerX == view.centerXAnchor
				
				$0.height == 100
				$0.centerY == view.centerYAnchor - 100
				
			}
		}
		currentHint = view.window?.hint {
			$0.content = message
			$0.buttonTitle = buttonTitle
			$0.onTap = { [weak self] in
				view.removeFromSuperview()
				self?.didSelect()
			}
            $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                    secondaryColor: UIColor(named:"HintFill")!,
                                                    textColor: .black,
                                                    cornerRadius: 8.0,
                                                    arrowEnabled: true,
                                                    arrowAbove: true))
            $0.updateHintContainerMargins()
            $0.updateTitleStackMargins()
			$0.layout {
				$0.centerY == image.bottomAnchor + 100
				$0.centerX == image.centerXAnchor
				$0.width == view.widthAnchor - 48
			
			}
		}
	}
	func removeHint(hint:String) {
		_ = state.removeCondition(with: hint)
	}
	func needHelp() {
		
		let time = tutorialAnimation.time + 3
		print("HINT:", time, ":",  progress(seconds:time))
		state.addCondition(atTime: progress(seconds:time), flagName: "hint") {
			[weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.tutorialAnimation.pause()
			
            weakSelf.maybeRemoveSelectNextTwoHint()
			
			//Otherwise let's give them a choice.
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content  = "".localized(ACTranslationKey.popup_tutorial_needhelp)
				$0.buttonTitle = "".localized(ACTranslationKey.popup_tutorial_remindme)
				$0.onTap = {[weak self] in
					weakSelf.currentHint?.removeFromSuperview()
					//Remove the hint so that it will fire again
					self?.removeHint(hint: "hint")
					//If they selected one we'll show the double hint.
					if self?.gridSelected == 1 {
						self?.addDoubleHint(hint: "hint", seconds: 0.0)
						self?.tutorialAnimation.resume()
						self?.phase = .showingReminder
					//If they selected two, then we show the single hint
					} else if self?.gridSelected == 2 {
						self?.addFinalHint(hint: "hint", seconds: 0.0)
						self?.tutorialAnimation.resume()
						self?.phase = .showingReminder

					} else {
						//Otherwise show the first,
						//the user has removed a selection before this hint appeared
						self?.addFirstHint(hint: "hint", seconds: 0.0)
						self?.tutorialAnimation.resume()
					}
					
				}
				
				$0.layout {
					$0.centerX == weakSelf.view.centerXAnchor
					$0.centerY == weakSelf.view.centerYAnchor
					
				}
			}
			
		}
	}
	func addDoubleHint(hint:String, seconds:TimeInterval = 3.0) {
		let time = tutorialAnimation.time + seconds
		print("HINT:", time, ":",  progress(seconds:time))
		state.addCondition(atTime: progress(seconds:time), flagName: hint) {
			[weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.tutorialAnimation.pause()
			let selected = weakSelf.test.collectionView.indexPathsForSelectedItems ?? []
			var index = weakSelf.test.symbolIndexPaths.filter {
				return !selected.contains($0)
			}
            if index.count > 2 {
                index.removeLast()
            }
			weakSelf.test.overlayCells(at: index)
			
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content  = "".localized(ACTranslationKey.popup_tutorial_tapbox2)
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: false))
                $0.updateHintContainerMargins()
                $0.titleStack.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 26, right: 8)
				$0.layout {
					
					$0.centerX == weakSelf.view.centerXAnchor
					$0.top >= weakSelf.view.safeAreaLayoutGuide.topAnchor
					$0.leading >= weakSelf.view.safeAreaLayoutGuide.leadingAnchor + 20
					$0.trailing <= weakSelf.view.safeAreaLayoutGuide.trailingAnchor - 20

					$0.bottom == weakSelf.test.collectionView.topAnchor - 8
				
					
				}
			}
			
		}
		
		
	}
	func addFinalHint(hint:String, seconds:TimeInterval = 3.0) {
		let time = tutorialAnimation.time + seconds
		print("HINT:", time, ":",  progress(seconds:time))
		state.addCondition(atTime: progress(seconds:time), flagName: hint) {
			[weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.tutorialAnimation.pause()
            guard let index = weakSelf.test.symbolIndexPaths.first(where: {weakSelf.test.collectionView.cellForItem(at: $0)?.isSelected == false}) else { return }
            guard let _ = weakSelf.test.overlayCell(at: index) else {
				return
			}
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = """
				*Hint:* One item was located
				in this box. Tap here.
				""".localized(ACTranslationKey.popup_tutorial_tapbox3)
				
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: false))
                $0.updateHintContainerMargins()
                $0.titleStack.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 26, right: 8)
                
				$0.layout {
					$0.centerX == weakSelf.view.centerXAnchor
					$0.top >= weakSelf.view.safeAreaLayoutGuide.topAnchor
					$0.leading >= weakSelf.view.safeAreaLayoutGuide.leadingAnchor + 20
					$0.trailing <= weakSelf.view.safeAreaLayoutGuide.trailingAnchor - 20

					$0.bottom == weakSelf.test.collectionView.topAnchor - 8
				}
			}
			
		}
		
		
	}
	func addFirstHint(hint:String, seconds:TimeInterval = 3.0) {
		let time = tutorialAnimation.time + seconds
		print("HINT:", time, ":",  progress(seconds:time))
		state.addCondition(atTime: progress(seconds:time), flagName: hint) {
			[weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.tutorialAnimation.pause()
			let index = weakSelf.test.symbolIndexPaths[min(2, weakSelf.gridSelected)]
			guard let cell = weakSelf.test.overlayCell(at: index) else {
				return
			}
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = """
				*Hint:* The cell phone was located here. Tap this box.
				""".localized(ACTranslationKey.popup_tutorial_cellbox)
                $0.targetView = cell
                $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                        secondaryColor: UIColor(named:"HintFill")!,
                                                        textColor: .black,
                                                        cornerRadius: 8.0,
                                                        arrowEnabled: true,
                                                        arrowAbove: true))
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()
                
				$0.layout {
					$0.centerX == weakSelf.view.centerXAnchor
					$0.width == 252
					
					if index.row/5 > 2 {
						//If above
						$0.bottom == cell.topAnchor + 40
						
					} else {
						
						$0.top == cell.bottomAnchor + 30
						
					}
					
				}
			}
			
		}
		
		
	}
    func maybeShowSelectNextTwoHint() {
        showingSelectNextTwo = true
        self.test.view.overlayView(withShapes: [.roundedRect(test.collectionView, 8, CGSize(width: 0, height: 0))])
        currentHint?.removeFromSuperview()
        self.removeHint(hint: "hint")
        self.currentHint = self.view.window?.hint {
            $0.content = "".localized(ACTranslationKey.popup_tutorial_tapbox)
            $0.configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
                                                    secondaryColor: UIColor(named:"HintFill")!,
                                                    textColor: .black,
                                                    cornerRadius: 8.0,
                                                    arrowEnabled: true,
                                                    arrowAbove: false))
            $0.updateHintContainerMargins()
            $0.titleStack.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 26, right: 8)
            $0.layout {
                $0.centerX == self.view.centerXAnchor
				$0.top >= self.view.safeAreaLayoutGuide.topAnchor
				$0.leading >= self.view.safeAreaLayoutGuide.leadingAnchor + 20
				$0.trailing <= self.view.safeAreaLayoutGuide.trailingAnchor - 20

				$0.bottom == self.test.collectionView.topAnchor - 8
            }
        }
    }
    
    func maybeRemoveSelectNextTwoHint() {
        guard let hint = self.currentHint else { return }
        if hint.content == "".localized(ACTranslationKey.popup_tutorial_tapbox) {
            self.currentHint?.removeFromSuperview()
            self.currentHint = nil
            showingSelectNextTwo = false
            self.removeHint(hint: "hint")
            
        }
        
    }
    
    func removeFinalHint() {
        self.currentHint?.removeFromSuperview()
        self.currentHint = nil
        self.removeHint(hint: "hint")
    }
    
    func checkGridSelected() {
        self.gridSelected = 0
        for i in 0...24
        {
            let value = (self.test.controller.get(selectedData: i, id: self.test.responseId, questionIndex: self.test.testNumber, gridType: .image)?.selection) ?? -1
            if value > -1
            {
                self.gridSelected += 1
            }
        }
        print("Grids Selected: \(self.gridSelected)")
    }

}
