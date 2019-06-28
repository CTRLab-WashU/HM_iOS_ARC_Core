//
//  Fonts.swift
//  Arc
//
//  Created by Philip Hayes on 6/26/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit

public struct Georgia {
	static public let family = "Georgia"
	public struct Face {
		static public let blackItalic = "BlackItalic"
	}
	public struct Font {
		static public let title = UIFont()
			.family(Georgia.family)
			.italicFont()
			.size(22.5)
		
	}
	public struct Style {
		static public func title(_ label:UILabel) {
			label.font = Georgia.Font.title
			label.numberOfLines = 0
			label.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)

		}
	}
}
