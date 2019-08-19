//
//  GoalDayTileGroup.swift
//  Arc
//
//  Created by Philip Hayes on 8/16/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public class GoalDayTileGroup: UIStackView {
	
	weak var contents:UIStackView!
	override init(frame: CGRect) {
		super.init(frame: .zero)
		build()
	}
	
	required init(coder: NSCoder) {
		super.init(coder: coder)
		build()
	}
	
	
	func build() {
		distribution = .fillEqually
		
	}
	public func add(tile name:String, progress:Double) {
		goalDayTile {
			
			$0.progressView.progress = progress
			$0.titleLabel.text = name
			
			if arrangedSubviews.count % 2 == 1 {
				$0.backgroundColor = ACColor.calendarItemBackground
			} else {
				$0.backgroundColor = .white
			}
		}
	}
	
	public func clear() {
		removeSubviews()
	}
	public func set(progress:Double, forIndex index:Int) {
		if let tile = arrangedSubviews[index] as? GoalDayTileGroup {
			tile.set(progress: progress, forIndex: index)
		}
	}
}
extension UIView {
	@discardableResult
	public func goalDayTileGroup(apply closure: (GoalDayTileGroup) -> Void) -> GoalDayTileGroup {
		custom(GoalDayTileGroup(), apply: closure)
	}

}
