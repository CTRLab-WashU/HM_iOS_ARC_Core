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
