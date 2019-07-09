//
//  TestIntroView.swift
//  Arc
//
//  Created by Philip Hayes on 7/8/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
import HMMarkup
public class InfoView: ACTemplateView {
	var nextPressed:(()->Void)?
	var infoContent:InfoContentView!
	
	public func setHeading(_ text:String?) {
		infoContent.setHeader(text)
	}
	
	public func setSubHeading(_ text:String?) {
		infoContent.setSubHeader(text)

	}
	public func setContentText(_ text:String?, template:[String:String] = [:]) {
		infoContent.setContent(text, template:template)

	}
	
	
	public override func header(_ view:UIView) {
		super.header(view)
	}
	
	override open func content(_ view: UIView) {
		super.content(view)
		infoContent = view.infoContent { _ in}
	}
	
	public override func footer(_ view:UIView) {
		super.footer(view)
		view.stack { [weak self] in
			$0.axis = .vertical
			$0.alignment = .center
			
			self?.nextButton = $0.acButton {
				$0.translatesAutoresizingMaskIntoConstraints = false
				$0.setTitle("Next", for: .normal)
				
				$0.addAction { [weak self] in
					self?.nextPressed?()
				}
			}
		}
	}
	
}
