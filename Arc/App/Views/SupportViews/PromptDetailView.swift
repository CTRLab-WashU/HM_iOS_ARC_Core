//
//  PromptDetailView.swift
//  Arc
//
//  Created by Philip Hayes on 7/8/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit


public class PromptDetailView: UIStackView {
	
	public var separatorWidth:CGFloat {
		get {
			return separator.relativeWidth
		}
		set {
			separator.relativeWidth = newValue
		}
	}
	public var detail:String? {
		get {
			return detailsLabel.text
		}
		set {
			detailsLabel.text = newValue
		}
	}
	weak var separator:ACHorizontalBar!
	weak var promptLabel:UILabel!
	weak var detailsLabel:UILabel!
	
	var renderer:HMMarkupRenderer?
	public init() {

		super.init(frame: .zero)
		axis = .vertical
		alignment = .fill
		spacing = 10
		promptLabel = acLabel {
			$0.text = ""
			Roboto.Style.heading($0)
			$0.textColor = .primaryText
			
		}
		separator = acHorizontalBar {
			$0.relativeWidth = 0.15
			$0.color = UIColor(named: "HorizontalSeparator")
			$0.layout {
				$0.height == 2 ~ 999
				
			}
		}
		detailsLabel = acLabel {
			
			Roboto.Style.body($0)
			$0.text = ""
			$0.textColor = .primaryText

			
		}
		
	}
	public func setPrompt(_ text:String?, template:[String:String] = [:]) {
		renderer = HMMarkupRenderer(baseFont: promptLabel.font)

		let markedUpString = renderer?.render(text: text ?? "", template:template)
		promptLabel.attributedText = markedUpString
		
	}
	public func setDetail(_ text:String?) {
		detailsLabel.text = text
	}
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
extension UIView {
	
	@discardableResult
	public func promptDetail(apply closure: (PromptDetailView) -> Void) -> PromptDetailView {
		return custom(PromptDetailView(), apply: closure)
	}
	
}

