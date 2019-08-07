//
//  HintView.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 7/11/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import HMMarkup
public class HintView : IndicatorView {
	var titleLabel:ACLabel!
	private var bar:ACHorizontalBar!
	public var button:ACButton!
	public var content:String? {
		get {
			return titleLabel.text
		}
		set {
			titleLabel.isHidden = (newValue == nil)

			titleLabel.text = newValue
		}
	}
	public var buttonTitle:String? {
		get {
			return button.titleLabel?.text
		}
		set {
			button.isHidden = (newValue == nil)
			bar.isHidden = button.isHidden
			button.setTitle(newValue, for: .normal)
			Roboto.PostProcess.link(button)

		}
	}
	public var onTap:(()->Void)?
	
	public init() {
		super.init(frame: .zero)
		stack {
			
			$0.isLayoutMarginsRelativeArrangement = true
			$0.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
			titleLabel = $0.acLabel {
				$0.isHidden = true
				$0.textAlignment = .center
				Roboto.Style.body($0, color:.black)
				
			}
		}
		
		bar = acHorizontalBar {
			$0.isHidden = true
			$0.relativeWidth = 1.0
			$0.layout {
				$0.height == 2
			}
		}
		button = acButton {
			$0.layout {
				$0.height == 36 ~ 500
			}
			$0.isHidden = true
			$0.primaryColor = .clear
			$0.secondaryColor = .clear
			$0.tintColor = .black
			Roboto.PostProcess.link($0)
			$0.addAction { [weak self] in
				self?.onTap?()
			}
		}
		container?.isLayoutMarginsRelativeArrangement = true
		container?.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
		configure(with: IndicatorView.Config(primaryColor: UIColor(named:"HintFill")!,
											 secondaryColor: UIColor(named:"HintFill")!,
											 textColor: .black,
											 cornerRadius: 8.0,
											 arrowEnabled: false))
	}
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func draw(_ rect: CGRect) {
		super.draw(rect)
		 let context = UIGraphicsGetCurrentContext()
		context?.setStrokeColor(UIColor(named:"HorizontalSeparator")!.cgColor)
		path?.lineWidth = 8
		path?.stroke()
	}
}
extension UIView {
	
	@discardableResult
	public func hint(apply closure: (HintView) -> Void) -> HintView {
		return custom(HintView(), apply: closure)
	}
	
}
