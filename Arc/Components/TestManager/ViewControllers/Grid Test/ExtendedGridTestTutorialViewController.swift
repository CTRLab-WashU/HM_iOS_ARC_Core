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
		case start, fs, fsTimed, recall, recallFirstStep, recallFirstChoiceMade, recallSecondChoiceMade, showingReminder,  showContinue, change, mechanics
	}
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
	
	let test:ExtendedGridTestViewController = .get()
	
    var showingMechanics = false
    var symbolSelected = false
	var selectionMade = false
    var showingSelectNextTwo = false
	var lockIncorrect = false
	var maxGridSelected = 3
	var gridSelected = 0
	var phase:TestPhase = .start
    var indicator:IndicatorView?
    var gridChoice:GridChoiceView?
    var currentIndex:IndexPath = []
    
    override func viewDidLoad() {
		duration = 26
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
			tutorialAnimation.resume()
            if self.gridChoice == nil {
                needHelp()
            }
		case .recallFirstChoiceMade, .recallSecondChoiceMade:
            if showingSelectNextTwo == false {
                test.view.clearOverlay()
                removeHint(hint: "hint")
            }
            showingSelectNextTwo = true
            tutorialAnimation.time = 19.5
            if self.gridChoice == nil {
                needHelp()
            }
            view.removeHighlight()
			tutorialAnimation.resume()
        case .recall:
            test.view.clearOverlay()
            view.removeHighlight()
            removeFinalHint()
            if self.gridChoice == nil {
                needHelp()
            }
            tutorialAnimation.resume()
		case .showContinue:
			test.view.clearOverlay()
			view.removeHighlight()
            removeFinalHint()
            test.collectionView.isUserInteractionEnabled = true
            showContinueButton()
        case .change:
            removeFinalHint()
            tutorialAnimation.resume()
            if symbolSelected == false {
                needChange()
            }
        case .mechanics:
            removeFinalHint()
            view.removeHighlight()
            tutorialAnimation.resume()
		case .showingReminder:
			removeHint(hint: "hint")
           
		}
		selectionMade = true
	}
	//MARK:-Delegate
	func didSelectGrid(indexPath: IndexPath) {
        //Don't need to check grid selected count in mechanics
        if showingMechanics == false {
            checkGridSelected()
        }
		switch gridSelected  {
		case 1:
            //Don't need to show this again if user removed or swapped items
            if symbolSelected == false {
                maybeShowSelectNextTwoHint()
            }
			phase = .recallFirstChoiceMade
            
        case 2:
            phase = .recallSecondChoiceMade
            
		case 3:
            removeFinalHint()
            test.collectionView.isUserInteractionEnabled = true
    
		default:
            //if 0 items selected
            if showingMechanics == false {
                phase = .recallFirstStep
            } else {
                phase = .mechanics
            }
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
        self.currentIndex = indexPath
        //remove highlight in first button hint
        if self.gridChoice != nil && gridSelected < 1 {
            test.collectionView.removeHighlight()
            tutorialAnimation.resume()
        //checks to see if cell selected has item
        } else if checkGridValue(index: indexPath.row) == true && self.gridChoice != nil {
            tutorialAnimation.time = 19.5
            didSelect()
            //tutorialAnimation.pause()
        //mechanics section
        } else if showingMechanics == true {
            didSelect()
        } else {
            test.collectionView.removeHighlight()
            test.view.clearOverlay()
            tutorialAnimation.time = 19.5
            didSelectGrid(indexPath: self.currentIndex)
            //tutorialAnimation.pause()
        }
        currentHint?.removeFromSuperview()
    }

    func hideImages() {
        for indexPath in self.test.collectionView.indexPathsForVisibleItems {
            guard let cell = self.test.collectionView.cellForItem(at: indexPath) as? GridImageCell else { return }
                cell.image.isHidden = true
        }
    }

	func setupScript() {
		state.addCondition(atTime: progress(seconds: 0), flagName: "start-0") { [weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.tutorialAnimation.pause()
			weakSelf.test.displaySymbols()
			weakSelf.test.view.overlayView(withShapes: [])
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = "This test has three parts. In the first part, you'll be asked to *remember the location* of three items. The items will be placed in a grid of boxes. *Remember which box each item is in.* You will have 3 seconds to study the locations.".localized(ACTranslationKey.popup_tutorial_rememberbox)
				$0.buttonTitle = "I'm Ready".localized(ACTranslationKey.popup_tutorial_ready)
				$0.onTap = { [weak self] in
					
					weakSelf.phase = .start
					self?.didSelect()
				}
				
				$0.layout {
					$0.centerY == weakSelf.view.centerYAnchor - 20
					$0.centerX == weakSelf.view.centerXAnchor

					$0.width == weakSelf.test.collectionView.widthAnchor - 75
					
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
		state.addCondition(atTime: progress(seconds: 3.5), flagName: "fs-1") { [weak self] in
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
                $0.configure(with: IndicatorView.Config(
                    primaryColor: UIColor(named:"HintFill")!,
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
		state.addCondition(atTime: progress(seconds: 3.5), flagName: "fs-2") { [weak self] in
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
        state.addCondition(atTime: progress(seconds: 11.4), flagName: "fs-3") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.test.collectionView.isUserInteractionEnabled = false
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
                    weakSelf.test.displayGrid()
				}
				
				$0.layout {
					$0.centerY == weakSelf.view.centerYAnchor
					$0.centerX == weakSelf.view.centerXAnchor
					
					$0.width == weakSelf.test.collectionView.widthAnchor - 75
					
				}
			}
			
		}
		state.addCondition(atTime: progress(seconds: 11.5), flagName: "symbols-0") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
            weakSelf.test.collectionView.isUserInteractionEnabled = false
            weakSelf.test.view.overlayView(withShapes: [])
            weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                In part three, place each item in its location from part one.
                """.localized(ACTranslationKey.popup_tutorial_selectbox)
                $0.buttonTitle = "I'm Ready".localized(ACTranslationKey.popup_tutorial_ready)
                $0.onTap = {
                    weakSelf.removeFinalHint()
                    weakSelf.view.clearOverlay()
                    weakSelf.tutorialAnimation.resume()
                }
                
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()
                
                $0.layout {
                    $0.centerY == weakSelf.view.centerYAnchor
                    $0.centerX == weakSelf.view.centerXAnchor
                    
                    $0.width == weakSelf.test.collectionView.widthAnchor - 75
                    
                }
            }
        }
		
        
        
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-1") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.test.collectionView.isUserInteractionEnabled = true
            weakSelf.addFirstHint(hint: "hint", seconds: 0.0)
            
        }
        state.addCondition(atTime: progress(seconds:25.5), flagName: "symbols-2") { [weak self] in
            guard let weakSelf = self else {
                return
            }
                weakSelf.tutorialAnimation.time = 19.5
                weakSelf.didSelect()
        }
	}
	func removeHint(hint:String) {
		_ = state.removeCondition(with: hint)
	}
    func endTutorial() {
        state.addCondition(atTime: progress(seconds: 26), flagName: "end") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.finishTutorial()
        }
    }
    func needMechanics() {
    //Show Hint for Moving Phone
        state.addCondition(atTime: progress(seconds:25), flagName: "mechanics-0")
        { [weak self] in
            guard let weakSelf = self else {
                return
            }
               
            weakSelf.tutorialAnimation.pause()
            weakSelf.showingMechanics = true
            weakSelf.test.view.overlayView(withShapes: [])
            weakSelf.test.collectionView.isUserInteractionEnabled = false
            weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = """
                    *Nice work!*\nIt looks like you didn't need any help with placement, but we want to make sure we still teach you how to swap and remove items before you move onto the actual test.
                    """.localized(ACTranslationKey.popup_tutorial_mechanics)
                $0.buttonTitle = "Show Me".localized(ACTranslationKey.button_showme)
                $0.onTap = {
                    weakSelf.phase = .mechanics
                    weakSelf.setMechanics()
                    weakSelf.test.continueButton.isHidden = true
                    weakSelf.removeFinalHint()
                    weakSelf.view.clearOverlay()
                    weakSelf.tutorialAnimation.resume()
                }
                           
                $0.updateHintContainerMargins()
                $0.updateTitleStackMargins()
               
                $0.layout {
                    $0.centerY == weakSelf.view.centerYAnchor
                    $0.centerX == weakSelf.view.centerXAnchor
                    $0.width == weakSelf.test.collectionView.widthAnchor - 75
                }
        }
    }
               
           state.addCondition(atTime: progress(seconds:25), flagName: "mechanics-1") { [weak self] in
               guard let weakSelf = self else {
                   return
               }
               weakSelf.tutorialAnimation.pause()
               
               weakSelf.test.collectionView.isUserInteractionEnabled = false
               weakSelf.changeOverlaySize()
               weakSelf.test.tapOnTheFsLabel.isHidden = false
               weakSelf.test.continueButton.isHidden = true
               weakSelf.currentHint = weakSelf.view.window?.hint {
                   $0.content = """
                       If you change your mind after placing an item, you can move it. Let's try it.
                       """.localized(ACTranslationKey.popup_tutorial_change)
                       
                   $0.updateHintContainerMargins()
                   $0.updateTitleStackMargins()
                   $0.buttonTitle = "Okay".localized(ACTranslationKey.button_okay)
                   $0.onTap = {
                       weakSelf.removeFinalHint()
                       weakSelf.view.clearOverlay()
                       weakSelf.tutorialAnimation.resume()
                   }
                   $0.layout {
                       $0.centerX == weakSelf.view.centerXAnchor
                       $0.width == 252
                       $0.bottom == weakSelf.view.bottomAnchor - 30
                   }
               }
           }
           
           state.addCondition(atTime: progress(seconds:25), flagName: "mechanics-2") { [weak self] in
               guard let weakSelf = self else {
                   return
               }
               weakSelf.tutorialAnimation.pause()
               weakSelf.test.tapOnTheFsLabel.isHidden = false
               weakSelf.test.continueButton.isHidden = true
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
                   $0.configure(with: IndicatorView.Config(
                       primaryColor: UIColor(named:"HintFill")!,
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

           state.addCondition(atTime: progress(seconds:25), flagName: "mechanics-3") { [weak self] in
               guard let weakSelf = self else {
                   return
               }
               weakSelf.tutorialAnimation.pause()
               weakSelf.test.tapOnTheFsLabel.isHidden = false
               weakSelf.test.continueButton.isHidden = true
               weakSelf.test.collectionView.isUserInteractionEnabled = false
               let index = IndexPath(row: 8, section: 0)
               weakSelf.changeOverlaySize()
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
                   $0.configure(with: IndicatorView.Config(
                       primaryColor: UIColor(named:"HintFill")!,
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
           state.addCondition(atTime: progress(seconds:25), flagName: "mechanics-4") { [weak self] in
               guard let weakSelf = self else {
                   return
               }
               weakSelf.tutorialAnimation.pause()
               
               weakSelf.test.tapOnTheFsLabel.isHidden = false
               weakSelf.test.continueButton.isHidden = true
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
                       Great! If you would like to clear a box with an item, first tap that box...
                       """.localized(ACTranslationKey.popup_tutorial_great_remove)
                   $0.targetView = cell
                   $0.configure(with: IndicatorView.Config(
                       primaryColor: UIColor(named:"HintFill")!,
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
                       
           state.addCondition(atTime: progress(seconds:25), flagName: "mechanics-5") { [weak self] in
               guard let weakSelf = self else {
                   return
               }
               weakSelf.tutorialAnimation.pause()
               
               weakSelf.test.tapOnTheFsLabel.isHidden = false
               weakSelf.test.continueButton.isHidden = true
               weakSelf.view.removeHighlight()
               weakSelf.test.collectionView.isUserInteractionEnabled = false
               weakSelf.gridChoice?.keyButton.isEnabled = false
               weakSelf.gridChoice?.penButton.isEnabled = false
           
               let removeButton = weakSelf.gridChoice?.removeButton
              
               //Highlight Remove Item button
            weakSelf.view.overlayView(withShapes: [.roundedRect((removeButton)!, 8, CGSize(width: 8-((removeButton?.bounds.width)!), height: 12-((removeButton?.bounds.height)!)))])
           
               //Tap Remove Button
               //Show Remove Item hint
               weakSelf.currentHint = weakSelf.view.window?.hint {
                   $0.content = """
                       ...then tap *Remove Item*.
                       """.localized(ACTranslationKey.popup_tutorial_remove)
                    $0.targetView = removeButton
                    removeButton?.addAction {
                       //weakSelf.tutorialAnimation.time = 26
                       weakSelf.tutorialAnimation.resume()
                   }
                   $0.configure(with: IndicatorView.Config(
                       primaryColor: UIColor(named:"HintFill")!,
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
                       
           state.addCondition(atTime: progress(seconds:25), flagName: "mechanics-6") { [weak self] in
               guard let weakSelf = self else {
                   return
               }
               weakSelf.tutorialAnimation.pause()
               weakSelf.test.tapOnTheFsLabel.isHidden = false
               weakSelf.test.continueButton.isHidden = true
               weakSelf.view.clearOverlay()
               weakSelf.hideImages()
               weakSelf.test.collectionView.isUserInteractionEnabled = false
           
               weakSelf.currentHint = weakSelf.view.window?.hint {
                   $0.content = """
                       Perfect! You've got it.
                       """.localized(ACTranslationKey.popup_tutorial_perfect)
                   
                   $0.configure(with: IndicatorView.Config(
                       primaryColor: UIColor(named:"HintFill")!,
                       secondaryColor: UIColor(named:"HintFill")!,
                       textColor: .black,
                       cornerRadius: 8.0,
                       arrowEnabled: false,
                       arrowAbove: false))
                   $0.updateHintContainerMargins()
                   $0.updateTitleStackMargins()
                   $0.buttonTitle = "Finish Tutorial".localized(ACTranslationKey.button_finish_tutorial)
                   $0.onTap = {
                       weakSelf.removeFinalHint()
                       weakSelf.finishTutorial()
                   }
                   $0.layout {
                       $0.centerX == weakSelf.view.centerXAnchor
                       $0.width == 252
                       $0.bottom == weakSelf.view.bottomAnchor - 30
                   }
               }
           }
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
                $0.content  = "Need Help?".localized(ACTranslationKey.popup_tutorial_needhelp)
                $0.buttonTitle = "Remind Me".localized(ACTranslationKey.popup_tutorial_remindme)
                $0.onTap = {[weak self] in
                    weakSelf.currentHint?.removeFromSuperview()
                    //Remove the hint so that it will fire again
                    weakSelf.removeFinalHint()
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

                    } else if self?.gridSelected == 3 {
                        
                        self?.phase = .showContinue
                    } else {
                        //the user has removed a selection before this hint appeared
                        //If the grid is clear, show all spots
                        self?.showSelectAllHint(hint:"hint")
                        self?.tutorialAnimation.resume()
                        self?.phase = .showingReminder
                    }
                }
                $0.layout {
                    $0.centerX == weakSelf.view.centerXAnchor
                    $0.width == 252
                    $0.bottom == weakSelf.view.bottomAnchor - 30
                }
            }
		}
	}
    func needChange() {
        let time = tutorialAnimation.time
        print("HINT:", time, ":",  progress(seconds:time))
        state.addCondition(atTime: progress(seconds:time), flagName: "hint") {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
            weakSelf.currentHint = weakSelf.view.window?.hint {
                $0.content = "Change your mind? Select a different item to replace, or tap *Remove Item* to clear."
                $0.buttonTitle = "Got It".localized(ACTranslationKey.popup_gotit)
                $0.onTap = {[weak self] in
                    self?.removeFinalHint()
                    weakSelf.symbolSelected = false
                    weakSelf.test.collectionView(weakSelf.test.collectionView, didDeselectItemAt: weakSelf.currentIndex)
                    weakSelf.tutorialAnimation.time = 19.5
                    //reset hints if Got It was touched and not all 3 items are selected
                    if weakSelf.gridSelected != 3 {
                        weakSelf.removeFinalHint()
                        weakSelf.needHelp()
                        weakSelf.tutorialAnimation.resume()
                    //keeps continue button on screen when all 3 items are visibile
                    } else {
                        weakSelf.phase = .showContinue
                    }
                }
                $0.layout {
                    $0.centerX == weakSelf.view.centerXAnchor
                    $0.width == 252
                    $0.height >= 134 ~ 750
                    if weakSelf.currentIndex.row <= 9 || weakSelf.currentIndex.row > 19 || weakSelf.test.collectionViewHeight.constant >= 400 {
                        $0.bottom <= weakSelf.view.bottomAnchor - 40 ~ 999
                    } else {
                        $0.top == weakSelf.view.topAnchor + 10
                    }
                }
            }
            //reset hints and set that mechanics aren't needed
            weakSelf.gridChoice?.removeButton.addAction {
                weakSelf.symbolSelected = true
                weakSelf.removeFinalHint()
                weakSelf.tutorialAnimation.time = 19.5
                weakSelf.needHelp()
                weakSelf.tutorialAnimation.resume()
            }
            //all buttons are set to skip mechanics if touched
            weakSelf.gridChoice?.keyButton.addAction {
                weakSelf.symbolSelected = true
            }
            weakSelf.gridChoice?.penButton.addAction {
                weakSelf.symbolSelected = true
            }
            weakSelf.gridChoice?.phoneButton.addAction {
                weakSelf.symbolSelected = true
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
            var index = weakSelf.test.symbolIndexPaths
            index.removeFirst()
			weakSelf.test.overlayCells(at: index)
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
            let keyCell = weakSelf.test.symbolIndexPaths[1]
            let penCell = weakSelf.test.symbolIndexPaths[2]
            if let value = weakSelf.test.controller.get(selectedData: penCell.row, id: weakSelf.test.responseId, questionIndex: weakSelf.test.testNumber, gridType: .image)?.selection, value > -1 {
                guard let _ = weakSelf.test.overlayCell(at: keyCell) else { return }
            } else {
                guard let _ = weakSelf.test.overlayCell(at: penCell) else { return }
            }
		}
	}
    func addFirstHint(hint:String, seconds:TimeInterval = 0.0) {
        let time = tutorialAnimation.time + seconds
        print("HINT:", time, ":",  progress(seconds:time))
        state.addCondition(atTime: progress(seconds: 14.5), flagName: "symbols-3") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            

            weakSelf.tutorialAnimation.pause()
            weakSelf.test.collectionView.isUserInteractionEnabled = true
            
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
                $0.configure(with: IndicatorView.Config(
                    primaryColor: UIColor(named:"HintFill")!,
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
        
        state.addCondition(atTime: progress(seconds:14.5), flagName: "symbols-4") { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
            self?.changeOverlaySize()
            
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
                $0.configure(with: IndicatorView.Config(
                    primaryColor: UIColor(named:"HintFill")!,
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
        
    }
    
    //Shows all 3 answers if first answer is removed
    func showSelectAllHint(hint:String, seconds:TimeInterval = 0.0) {
        let time = tutorialAnimation.time + seconds
        print("HINT:", time, ":",  progress(seconds:time))
        state.addCondition(atTime: progress(seconds:time), flagName: hint) {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.tutorialAnimation.pause()
            weakSelf.tutorialAnimation.time = 19.5
            let index = weakSelf.test.symbolIndexPaths
            weakSelf.test.overlayCells(at: index)
        }
    }
    func maybeShowSelectNextTwoHint() {
        showingSelectNextTwo = true
        self.view.clearOverlay()
        self.test.collectionView.isUserInteractionEnabled = true
        self.removeFinalHint()
        self.currentHint = self.view.window?.hint {
            $0.content = """
            Great! Now, place the other two items on the grid.
            """.localized(ACTranslationKey.popup_tutorial_tapbox)
            $0.configure(with: IndicatorView.Config(
            primaryColor: UIColor(named:"HintFill")!,
            secondaryColor: UIColor(named:"HintFill")!,
            textColor: .black,
            cornerRadius: 8.0,
            arrowEnabled: false,
            arrowAbove: false))
            $0.updateHintContainerMargins()
            $0.updateTitleStackMargins()
            $0.layout {
                $0.centerX == self.view.centerXAnchor
                
                $0.width == 252
                $0.bottom == self.view.bottomAnchor - 30

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
       
        showContinueButton()
        
        print("Grids Selected: \(self.gridSelected)")
    }
    //Checks Value of Grid Cell
    //Returns true if the Cell contains a symbol
    func checkGridValue(index:Int) -> Bool {
        let value = (self.test.controller.get(selectedData: index, id: self.test.responseId, questionIndex: self.test.testNumber, gridType: .image)?.selection) ?? -1
        if value > -1 && self.showingMechanics == false && self.gridChoice != nil
        {
            phase = .change
            return true
        }
        return false
    }
    func setMechanics() {
        for indexPath in self.test.collectionView.indexPathsForVisibleItems {
            _ = self.test.controller.unsetValue(responseIndex: indexPath.row, questionIndex: self.test.testNumber, gridType: .image, id: self.test.responseId)
        }
        let index = self.test.symbolIndexPaths[0]
        _ = self.test.controller.setValue(responseIndex: index.row, responseData: 1, questionIndex: self.test.testNumber, gridType: .image, time: Date(), id: self.test.responseId)
        self.test.collectionView.reloadData()
    }
    //Only Show Continue Button when all 3 symbols are shown
    //Extra condition check to see if a symbol has been moved or removed, then move to end of test if true
    func showContinueButton() {
        if self.gridSelected == 3 {
            self.phase = .showContinue
            self.test.tapOnTheFsLabel.isHidden = true
            self.test.continueButton.isHidden = false
            self.test.continueButton.addAction { [weak self] in
                if self?.symbolSelected == true {
                    self?.endTutorial()
                } else {
                    self?.tutorialAnimation.time = 25
                    self?.needMechanics()
                    self?.tutorialAnimation.resume()
                }
            }
        } else {
            self.test.tapOnTheFsLabel.isHidden = false
            self.test.continueButton.isHidden = true
        }
    }
    //Changes Overlay window size so we don't lose access to the Grid Choice buttons
    func changeOverlaySize() {
        var height = self.test.collectionStack.bounds.height - self.test.collectionViewHeight.constant + 20
        if self.test.collectionViewHeight.constant >= 400 {
            height += 50
        }
        //Darken Area around Indicator and top of cell
        self.view.overlayView(withShapes: [.roundedRect(self.test.collectionView, 8, CGSize(width: 5, height: height))])
        
    }
}
