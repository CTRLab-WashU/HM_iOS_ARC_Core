//
//  TestNavigationController.swift
// Arc
//
//  Created by Philip Hayes on 10/23/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

open class InstructionNavigationController: UINavigationController {
	var app = Arc.shared
	public var instructions:[Introduction.Instruction]?
	public var nextVc:UIViewController?
	public var nextState:State?
	public var titleOverride:String?
	
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
    }
	@discardableResult
	open func load(instructions template:String) -> Introduction {
		guard let asset = NSDataAsset(name: template) else {
			fatalError("Missing data asset: \(template)")
		}
		do {
			let intro = try JSONDecoder().decode(Introduction.self, from: asset.data)
			instructions = intro.instructions

			return intro
		} catch {
			fatalError("Invalid asset format: \(template) - Error: \(error.localizedDescription)")
			
		}
	}
	
	override open func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		_ = displayIntro(index: 0)
	}
	
	private func displayIntro(index:Int) -> Bool {
		
		if let instructions = instructions,
			index < instructions.count
		{
			let instruction = instructions[index]
			let vc:IntroViewController = IntroViewController()
			vc.style = IntroViewControllerStyle(rawValue: instruction.style ?? "standard")!
			vc.loadViewIfNeeded()
			vc.nextButtonTitle = instruction.nextButtonTitle
            vc.nextButtonImage = instruction.nextButtonImage
			self.pushViewController(vc, animated: true)
//
			vc.set(heading:     titleOverride ?? instruction.title,
				   subheading:  instruction.subtitle,
				   content:     instruction.preface)

			vc.nextPressed = {
				[weak self] in
				self?.next(nextQuestion: index + 1)
			}
			return true
		}
		return false
	}
	private func next(nextQuestion: Int) {
		if displayIntro(index: self.viewControllers.count) {
			
		} else {
			
			
			//Subclasses may perform conditional async operations
			//that determine if the app should proceed.
			if let nextState = self.nextState {
				app.appNavigation.navigate(state: nextState, direction: .toRight)
			} else {
				if let vc = nextVc {
					app.appNavigation.navigate(vc: vc, direction: .toRight)

				} else {
					fatalError("Failed to set either state or view controller.")
				}

			}
		}
	}


}
