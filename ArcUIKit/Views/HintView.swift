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
	var button:ACButton!
	var content:String? {
		get {
			return titleLabel.text
		}
		set {
			titleLabel.text = newValue
		}
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		titleLabel = acLabel {
			$0.isHidden = true

			Roboto.Style.body($0, color:.black)
		}
		button = acButton {
			$0.isHidden = true
			$0.primaryColor = .clear
			$0.secondaryColor = .clear
			$0.tintColor = .black
			
		}
		
	}
	public init() {
		super.init(frame: .zero)
		titleLabel = acLabel {
			Roboto.Style.body($0, color:.black)
		}
		button = acButton {
			$0.primaryColor = .clear
			$0.secondaryColor = .clear
			$0.tintColor = .black
			
		}
	}
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
