//
//  Roboto.swift
//  Arc
//
//  Created by Philip Hayes on 6/26/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import HMMarkup
public struct Roboto {
	public static let family = "Roboto"
	
	
	public struct Face {
		public static let regular = "Regular"
		public static let black = "Black"
		public static let light = "Light"
		public static let lightItalic = "LightItalic"
		public static let thin = "Thin"
		public static let mediumItalic = "MediumItalic"
		public static let medium = "Medium"
		public static let blackItalic = "BlackItalic"
	}
	public struct Font {
		public static let body = UIFont()
			
			.family(Roboto.family)
			.face(Roboto.Face.regular)
			.size(18)
		public static let bodyBold = Font.body
			.boldFont()
			
		
		public static let heading = UIFont()
			.family(Roboto.family)
			.face(Roboto.Face.regular)
			.size(26)
		public static let headingBold = UIFont()
			.family(Roboto.family)
			.boldFont()
			.size(26)
		public static let italic = UIFont()
			.family(Roboto.family)
			.italicFont()
			.size(18)
	
	}
	
	///Attributes for various uses
	public struct Attributes {
		public static let link = [ NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor(named: "Primary") ?? .blue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium) ] as [NSAttributedString.Key : Any]
	}
	
	
	/// Use post processors after you make changes to text in a particular view
	public struct PostProcess {
		public static func renderMarkup (_ label:UILabel, template:[String:String] = [:]) {
			let renderer:HMMarkupRenderer = HMMarkupRenderer(baseFont: label.font)
			
			
			let markedUpString = renderer.render(text: label.text ?? "", template:template)
			label.attributedText = markedUpString
			
			lineHeight(label)
		}
		public static func link (_ label:UILabel) {
			
			let attrString = NSAttributedString(string:label.text ?? "", attributes: Attributes.link)
			label.attributedText = attrString
			
		}
		public static func link (_ button:UIButton) {
			
			let attrString = NSAttributedString(string:button.title(for: .normal) ?? "", attributes: Attributes.link)
			
			button.setAttributedTitle(attrString, for: .normal)
		}
		public static func lineHeight (_ label:UILabel) {
			
			let attributedString = NSMutableAttributedString(attributedString: label.attributedText ?? NSAttributedString(string: label.text ?? ""))
			
			
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 7
			attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
			label.attributedText = attributedString
		}
	}
	public struct Style {
		
		public static func error(_ label:UILabel) {
			label.font = Roboto.Font.italic
			label.numberOfLines = 0
			label.textColor = #colorLiteral(red: 0.6000000238, green: 0, blue: 0, alpha: 1)
			
		}
		public static func body(_ label:UILabel) {
			label.font = Roboto.Font.body
			label.numberOfLines = 0
			label.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		}
		public static func bodyBold(_ label:UILabel) {
			label.font = Roboto.Font.bodyBold
			label.numberOfLines = 0
			label.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		}
		public static func heading(_ label:UILabel) {
			label.font = Roboto.Font.heading
			label.numberOfLines = 0
			
			label.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		}
		public static func headingBold(_ label:UILabel) {
			label.font = Roboto.Font.headingBold
			label.numberOfLines = 0
			label.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		}
		public static func body(_ label:UITextView) {
			label.font = Roboto.Font.body
			label.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		}
		public static func bodyBold(_ label:UITextView) {
			label.font = Roboto.Font.bodyBold
			label.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		}
		public static func heading(_ label:UITextView) {
			label.font = Roboto.Font.heading
			
			label.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		}
		public static func headingBold(_ label:UITextView) {
			label.font = Roboto.Font.headingBold
			label.textColor = #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		}
	}
	
}
