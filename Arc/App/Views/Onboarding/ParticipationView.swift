//
//  ParticipationView.swift
//  Arc
//
//  Created by Philip Hayes on 7/11/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public class ParticipationView: ACTemplateView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	
	public override init() {
		super.init()
		backgroundColor = .white
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func content(_ view: UIView) {
		view.infoContent {
			$0.alignment = .leading
			$0.textColor = UIColor(named:"Primary Text")
			$0.setHeader("Thank you for your time.")
			$0.setSeparatorWidth(0.15)
			$0.setContent("Your study coordinator will be notified that you do not wish to participate at this time. Your study coordinator may also contact you to confirm this information.")
			
		}
	}
}
