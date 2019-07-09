//
//  InfoContentView.swift
//  Arc
//
//  Created by Philip Hayes on 7/8/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
import HMMarkup
public class InfoContentView: UIStackView {
	weak var headingLabel: UILabel?
	weak var subheadingLabel: UILabel?
	weak var contentTextView: UITextView?
	var textColor = UIColor(named: "Secondary Text")

	public init() {
		super.init(frame: .zero)
		spacing = 8
		axis = .vertical
		alignment = .fill
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = UIEdgeInsets(top: 24,
									 left: 24,
									 bottom: 24,
									 right: 24)
	}
	public func setHeader(_ text:String?) {
		if let view = headingLabel {
			view.text = text
		} else {
			headingLabel = acLabel {
				$0.textAlignment = .center

				Roboto.Style.headingBold($0,
										 color:textColor)
				$0.text = text
				
			}
		}
	}
	
	public func setSubHeader(_ text:String?) {
		if let view = subheadingLabel {
			view.text = text
		} else {
			subheadingLabel = acLabel {
				$0.textAlignment = .center

				Roboto.Style.body($0,
								  color:UIColor(red:0.4, green:0.78, blue:0.78, alpha:1))
				$0.text = text
			}
		}
	}
	public func setContent(_ text:String?, template:[String:String] = [:]) {
		if let view = contentTextView {
			view.text = text
		} else {
			contentTextView = acTextView {
				$0.contentInset = .zero
				$0.isEditable = false
				$0.backgroundColor = .clear
				$0.textAlignment = .center
				$0.isSelectable = true
				Roboto.Style.body($0,
								  color:textColor)
				
				$0.text = text
				
				
			}
		}
		Roboto.PostProcess.renderMarkup(contentTextView!, template: template)
	}
	
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension UIView {
	
	@discardableResult
	public func infoContent(apply closure: (InfoContentView) -> Void) -> InfoContentView {
		custom(InfoContentView(), apply: closure)
	}
	
}
