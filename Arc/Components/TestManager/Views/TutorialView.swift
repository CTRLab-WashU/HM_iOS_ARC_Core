//
//  TutorialView.swift
//  Arc
//
//  Created by Philip Hayes on 7/3/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
class TutorialView: UIStackView {
	var headerView:UIView!
	var progressBar:ACHorizontalBar!
	var containerView:UIView!
	var contentView:UIViewController?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	init() {
		
		super.init(frame: .zero)
		header()
		container()
	}
	public func header() {
		headerView = view {
			$0.backgroundColor = .blue
			$0.stack {
				$0.acHorizontalBar {
					$0.relativeWidth = 0.5
				}
				
				let v = $0
				$0.layout {
				
					$0.top == v.superview!.topAnchor ~ 999
					$0.trailing == v.superview!.trailingAnchor ~ 999
					$0.bottom == v.superview!.bottomAnchor ~ 999
					$0.leading == v.superview!.leadingAnchor ~ 999
					
				}
			}
		}
	}
	public func container() {
		containerView = view {
			$0.backgroundColor = .white
		}
	}
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	public func setContent(viewController:UIViewController) {
		viewController.removeFromParent()
		viewController.view.removeFromSuperview()
		containerView.anchor(view: viewController.view)
		
	}
	
}
