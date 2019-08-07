//
//  ACHomeTabViewController.swift
//  EXR
//
//  Created by Philip Hayes on 8/6/19.
//  Copyright © 2019 healthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public extension Notification.Name {
	static let ACHomeStartOnboarding = Notification.Name(rawValue: "ACHomeStartOnboarding")
}
class ACHomeTabViewController: UITabBarController {
	
	let onboardingKeys:[ACTranslationKey] = [.popup_tab_home,
											 .popup_tab_progress,
											 .popup_tab_earnings,
											 .popup_tab_resources]
	
	let buttonKeys:[ACTranslationKey] = [.popup_next,
										 .popup_next,
										 .popup_next,
										 .popup_done]
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(displayOnboarding),
											   name: .ACHomeStartOnboarding,
											   object: nil)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	@objc func displayOnboarding() {
		self.showTab(index: 0)
	}
	
	func showTab(index:Int) {
		
		
		var views:[UIControl] = tabBar.subviews.filter {$0 is UIControl} as! [UIControl]
		guard index < views.count else {
			view.window?.clearOverlay()
			view.isUserInteractionEnabled = true

			return
		}
		
		views.sort {$0.frame.minX < $1.frame.minX}
		let v = views[index]
		dump(v)
		view.window?.overlayView(withShapes: [.circle(v)])
		view.isUserInteractionEnabled = false
		view.window?.hint {
			let hint = $0
			$0.layout {
				$0.centerX == v.centerXAnchor ~ 500
				$0.bottom == v.topAnchor - 20
				$0.leading >= view.leadingAnchor + 24
				$0.trailing <= view.trailingAnchor - 24
				$0.width == 232
				$0.height == 146
			}
			$0.content = "".localized(self.onboardingKeys[index])
			$0.buttonTitle = "".localized(self.buttonKeys[index])
			$0.onTap = {[unowned self] in
				hint.removeFromSuperview()
				self.showTab(index: index + 1)
			}
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

}
