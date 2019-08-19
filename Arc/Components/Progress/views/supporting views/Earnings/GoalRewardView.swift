//
//  GoalReward.swift
//  Arc
//
//  Created by Philip Hayes on 8/15/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public class GoalRewardView: UIView {
	weak var titleLabel:ACLabel!
	weak var backgroundView:GoalBackgroundView!
	var isUnlocked:Bool = false{
		didSet {
			backgroundView.config.isUnlocked = isUnlocked
			if isUnlocked {
				Roboto.Style.goalReward(titleLabel, color: ACColor.badgeText)

			} else {
				Roboto.Style.goalReward(titleLabel, color:.gray)

			}
		}
	}
	public init() {
		super.init(frame: .zero)
		backgroundView = goalBackgroundView { [unowned self] in
			$0.attachTo(view: self)
			$0.layout {
				$0.height == 46 ~ 999
			}
			$0.config.isUnlocked = false
			self.titleLabel = $0.acLabel {
				$0.attachTo(view: $0.superview)

				Roboto.Style.goalReward($0, color: ACColor.badgeText)
			}
		}
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	public func set(text:String) {
		titleLabel.text = text
	}
	
}
extension UIView {
	@discardableResult
	public func goalReward(apply closure: (GoalRewardView) -> Void) -> GoalRewardView {
		return custom(GoalRewardView(), apply: closure)
	}
}

