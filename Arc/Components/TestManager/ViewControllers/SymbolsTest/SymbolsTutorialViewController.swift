//
//  SymbolsTutorialViewController.swift
//  Arc
//
//  Created by Philip Hayes on 7/22/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
class SymbolsTutorialViewController: ACTutorialViewController, SymbolsTestViewControllerDelegate {

    public var symbols:[Int:UIImage] = [0: UIImage(named: "tutorial_symbol 1", in: Bundle(for: SymbolsTutorialViewController.self), compatibleWith: nil)!,
                                        1: UIImage(named: "tutorial_symbol 2", in: Bundle(for: SymbolsTutorialViewController.self), compatibleWith: nil)!,
                                        2: UIImage(named: "tutorial_symbol 3", in: Bundle(for: SymbolsTutorialViewController.self), compatibleWith: nil)!,
                                        3: UIImage(named: "tutorial_symbol 4", in: Bundle(for: SymbolsTutorialViewController.self), compatibleWith: nil)!,
                                        4: UIImage(named: "tutorial_symbol 5", in: Bundle(for: SymbolsTutorialViewController.self), compatibleWith: nil)!,
                                        5: UIImage(named: "tutorial_symbol 6", in: Bundle(for: SymbolsTutorialViewController.self), compatibleWith: nil)!,
                                        6: UIImage(named: "tutorial_symbol 7", in: Bundle(for: SymbolsTutorialViewController.self), compatibleWith: nil)!,
                                        7: UIImage(named: "tutorial_symbol 8", in: Bundle(for: SymbolsTutorialViewController.self), compatibleWith: nil)!]
    
    var test:SymbolsTestViewController = .get(nib: "SymbolsTestTutorialViewController", bundle: Bundle(for: SymbolsTestViewController.self))
	var selectionMade:Bool = false
	var questionsAnswered = 0
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
		duration = 15
        super.viewDidLoad()
		
		test.isPracticeTest = true
		test.delegate = self
		test.view.isUserInteractionEnabled = false
		setupScript()
		addChild(test)
		customView.setContent(viewController: test)
		
		self.test.symbols = self.symbols
        
        // Do any additional setup after loading the view.
        if self.get(flag: .symbols_tutorial_shown) == false {
            self.customView.firstTutorialRun()
        }
    }
	override public func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		view.window?.clearOverlay()
		view.removeHighlight()
		currentHint?.removeFromSuperview()
		
	}
    
    override func finishTutorial() {
        self.set(flag: .symbols_tutorial_shown)
        super.finishTutorial()
    }

	func didSelect(_ enableInteraction:Bool = false){
		view.window?.clearOverlay()
		view.removeHighlight()
		currentHint?.removeFromSuperview()
		
		tutorialAnimation.resume()
		removeHint(hint: "hint")
		
		
	}
	public func didSelect(index: Int) {
		selectionMade = true
		
		didSelect()
		tutorialAnimation.pause()
		test.view.isUserInteractionEnabled = false
		if test.questionIndex <= 1 {
			currentHint = view.window?.hint { [weak self] in
				if self?.test.questionIndex == 0 {
					$0.content = """
					*Great job!*
					Let’s try a couple more
					for practice.
					"""
					$0.buttonTitle = "Next"
				} else {
					$0.content = """
					*Nice!*
					One more...
					"""
					$0.buttonTitle = "Next"
				}
				$0.onTap = { [weak self] in
					self?.test.next()
					self?.didSelect()
					self?.addHint(hint: "hint")
					self?.test.view.isUserInteractionEnabled = true

				}
				guard let weakSelf = self else {return}
				$0.layout {
					$0.bottom == weakSelf.test.selectionContainer.topAnchor + 20
					$0.centerX == weakSelf.test.selectionContainer.centerXAnchor
					$0.width == 252
				}
			}
		} else {
			finishTutorial()
		}
				
				
	}
	
	func setupScript() {
		state.addCondition(atTime: progress(seconds:0.5), flagName: "start-0") {
			[weak self] in
			guard let weakSelf = self else {
				return
			}
            weakSelf.test.option2.alpha = 1.0
			weakSelf.test.option2.overlay()
			weakSelf.tutorialAnimation.pause()
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = """
				*This is a tile.*
				Each tile includes a pair
				of symbols.
				"""
				$0.buttonTitle = "Next"
				$0.onTap = { [weak self] in
					
					self?.didSelect()
				}
				
				$0.layout {
					$0.top == weakSelf.test.option2.bottomAnchor + 20
					$0.centerX == weakSelf.test.option2.centerXAnchor
					$0.width == 252
					
				}
			}
		}
		state.addCondition(atTime: progress(seconds:0.6), flagName: "start-1") {
			[weak self] in
			guard let weakSelf = self else {
				return
			}
            weakSelf.test.option1.alpha = 1.0
            weakSelf.test.option3.alpha = 1.0
			weakSelf.test.choiceContainer.overlay()
			weakSelf.tutorialAnimation.pause()

			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = """
				You will see *three tiles* on the top of the screen…
				"""
				$0.buttonTitle = "Next"
				$0.onTap = { [weak self] in
					
					self?.didSelect()
				}
				
				$0.layout {
					$0.top == weakSelf.test.option2.bottomAnchor + 20
					$0.centerX == weakSelf.test.option2.centerXAnchor
					$0.width == 252
					
				}
			}
		}
		
		state.addCondition(atTime: progress(seconds:0.7), flagName: "start-2") {
			[weak self] in
			guard let weakSelf = self else {
				return
			}
            weakSelf.test.choice1.alpha = 1.0
            weakSelf.test.choice2.alpha = 1.0
			weakSelf.test.selectionContainer.overlay()
			weakSelf.tutorialAnimation.pause()
			
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = """
				…and *two tiles* on the bottom.
				"""
				$0.buttonTitle = "Next"
				$0.onTap = { [weak self] in
					
					self?.didSelect()
				}
				
				$0.layout {
					$0.bottom == weakSelf.test.selectionContainer.topAnchor + 20
					$0.centerX == weakSelf.test.selectionContainer.centerXAnchor
					$0.width == 252
					
				}
			}
		}
		state.addCondition(atTime: progress(seconds:1.0), flagName: "start-3") {
			[weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.test.view.isUserInteractionEnabled = true

			weakSelf.addHint(hint: "hint")

			
		}
		
		
	
		
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	func removeHint(hint:String) {
		_ = state.removeCondition(with: hint)
	}
	func addHint(hint:String) {
		let time = tutorialAnimation.time + 3.0
		print("HINT:", time)
		state.addCondition(atTime: progress(seconds:time), flagName: hint) {
			[weak self] in
			guard let weakSelf = self else {
				return
			}
			weakSelf.tutorialAnimation.pause()
			guard let selection = weakSelf.test.correctSelection else {
				return
			}
			weakSelf.view.window?.overlayView(withShapes: [.roundedRect(selection.0, 8.0), .roundedRect(selection.1, 8.0)])
            selection.0.highlight()
			weakSelf.currentHint = weakSelf.view.window?.hint {
				$0.content = """
				Tap this matching tile.
				""".localized("popup_tutorial_tiletap")
				
				
				$0.layout {
					$0.bottom == weakSelf.view.bottomAnchor - 30
					$0.centerX == weakSelf.view.centerXAnchor
					$0.width == 252
					
				}
			}
			
		}
		
		
	}
	
	
}
