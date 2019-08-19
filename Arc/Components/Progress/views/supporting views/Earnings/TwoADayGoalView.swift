//
//  TwoADayGoalView.swift
//  Arc
//
//  Created by Philip Hayes on 8/19/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import ArcUIKit
public class TwoADayGoalView : GoalView {
	
	weak public var progressGroup:GoalDayTileGroup!
	
	override func buildContent(view: UIView) {
		
		self.goalBodyLabel = view.acLabel {
			Roboto.Style.body($0)
			$0.text = "".localized(ACTranslationKey.earnings_2aday_body)
		}
		
		//If you don't have anything to set use _ in
		self.progressGroup = view.goalDayTileGroup { _ in}
	}
	public func add(tiles:[String]) {
		for i in tiles {
			add(tile: i, progress: 0.0)
		}

	}
	public func add(tiles:[(String, Double)]) {
		for i in tiles {
			add(tile: i.0, progress: i.1)
		}
		
	}
	public func add(tile:String, progress:Double) {
		progressGroup.add(tile: tile, progress: progress)
	}
	public func set(progress:Double, forIndex index:Int) {
		progressGroup.set(progress: progress, forIndex: index)
	}
}

extension UIView {
	@discardableResult
	public func twoADayGoalView(apply closure: (TwoADayGoalView) -> Void) -> TwoADayGoalView {
		custom(TwoADayGoalView(), apply: closure)
	}
}
