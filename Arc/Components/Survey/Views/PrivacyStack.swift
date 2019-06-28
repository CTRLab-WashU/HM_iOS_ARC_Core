//
//  PrivacyStack.swift
//  Arc
//
//  Created by Philip Hayes on 6/28/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit



public class PrivacyStack: UIView {
	weak var button:UIButton!
	public init() {
		super.init(frame: .zero)
		
		stack { [weak self] in
			$0.axis = .vertical
			$0.alignment = .center
			
			$0.acLabel {
				$0.text = "By signing in you agree to our"
					.localized("bysigning_key")
				
			}
			
			self?.button = $0.button {
				$0.setTitle("Privacy Policy".localized("privacy_linked"),
									  for: .normal)
				Roboto.PostProcess.link($0)
			}
		}
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	/*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


extension UIView {
	
	@discardableResult
	public func privacyStack(apply closure: (PrivacyStack) -> Void) -> PrivacyStack {
		custom(PrivacyStack(), apply: closure)
	}
	
}
