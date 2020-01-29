//
//  CancelButton.swift
// Arc
//
//  Created by Philip Hayes on 10/24/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit


open class CancelButton : UIButton {
	override open func setTitle(_ title: String?, for state: UIControl.State) {
		let attributedString = NSAttributedString(string: title ?? "", attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue,
																					NSAttributedString.Key.foregroundColor : UIColor(named:"Primary")!])
		
		super.setAttributedTitle(attributedString, for: .normal)
	}
	
}
open class BoldCancelButton : UIButton {
	override open func setTitle(_ title: String?, for state: UIControl.State) {
		let attributes:[NSAttributedString.Key:Any] = [
			.foregroundColor : UIColor(named: "Primary") as Any,
			.font : UIFont(name: "Roboto-Regular", size: 18.0)?.boldFont() as Any,
			.underlineStyle: NSUnderlineStyle.single.rawValue
		]
		let attributedString = NSAttributedString(string: title ?? "", attributes: attributes)
		
		super.setAttributedTitle(attributedString, for: .normal)
	}
	
}
