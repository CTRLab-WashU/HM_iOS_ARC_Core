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
/// This view has functions that can be called in any order to change the
/// composition of the view itself. Each method once called will keep its original position.
public class InfoContentView: UIStackView {
	weak var headingLabel: UILabel?
	weak var subheadingLabel: UILabel?
	weak var contentLabel: UILabel?
	weak var contentTextView: UITextView?
	weak var separator:ACHorizontalBar!

	var textColor = UIColor(named: "Secondary Text")

	public init() {
		super.init(frame: .zero)
		spacing = 20
		axis = .vertical
		alignment = .fill
		
		
	}
	/// Using option type functions to lazy-add subviews allows the view to be
	/// recomposed based on the order that the options are called.
	/// - Parameter width: A value between 0 and 1
	public func setSeparatorWidth(_ width:CGFloat)
	{
		if let view = separator {
			view.relativeWidth = width
		} else {
			//Add a horizontal bar to the view AND assign it to
			//the separator variable
			separator = acHorizontalBar {
				
				$0.relativeWidth = width
				$0.layout { [weak self] in
					$0.height == 2 ~ 999
					$0.width == self!.widthAnchor ~ 500
				}
			}
		}
	}
	public func setHeader(_ text:String?)
	{
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
	public func setContentLabel(_ text:String?, template:[String:String] = [:]) {
		
		let text = Text.replaceIn(text, withTemplate: template)
		
		if let view = contentLabel {
			view.text = text
		} else {
			contentLabel = acLabel {
				
				$0.backgroundColor = .clear
				$0.textAlignment = .left

				Roboto.Style.body($0,
								  color:textColor)
				$0.text = text
				
				$0.layout {
					$0.width == self.widthAnchor ~ 400
				}
				
			}
		}
		//Roboto.PostProcess.renderMarkup(contentTextView!, template: template)
	}
	public func setContent(_ text:String?, template:[String:String] = [:]) {
		
		let text = Text.replaceIn(text, withTemplate: template)
		
		if let view = contentTextView {
			view.text = text
		} else {
			contentTextView = acTextView {
				$0.contentInset = .zero
				$0.isEditable = false
				$0.backgroundColor = .clear
				$0.textAlignment = .left
				$0.contentInset = .zero
				$0.isSelectable = true
				
				Roboto.Style.body($0,
								  color:textColor)
				
				$0.text = text
				
				$0.layout {
					$0.width == self.widthAnchor ~ 400
				}
				
			}
		}
		//Roboto.PostProcess.renderMarkup(contentTextView!, template: template)
	}
	
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension UIView {
	
	@discardableResult
	public func infoContent(apply closure: (InfoContentView) -> Void) -> InfoContentView {
		return custom(InfoContentView(), apply: closure)
	}
	
}
