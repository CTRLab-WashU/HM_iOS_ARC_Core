//
//  TestCountDownView.swift
//  Arc
//
//  Created by Philip Hayes on 8/5/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public class TestCountDownView: UIView {
	weak var countLabel:ACLabel!
	public override init(frame: CGRect) {
		super.init(frame: .zero)
		build()
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		build()
	}
	
	private func build(){
		backgroundColor = .white
		stack { [weak self] in
			let stack = $0
			
			
			$0.layout {
				$0.centerX == self!.centerXAnchor
				$0.centerY == self!.centerYAnchor - 40
				
			}
			$0.axis = .vertical
			$0.alignment = .center
			$0.acLabel {
				stack.setCustomSpacing(32, after: $0)
				$0.text = "".localized(ACTranslationKey.testing_begin)
				Roboto.Style.subHeading($0, color: ACColor.badgeText)
			}

			self?.countLabel = $0.acLabel {
				
				stack.setCustomSpacing(12, after: $0)
				$0.text = "3"
				Georgia.Style.veryLargeTitle($0)
			}
			
			$0.acHorizontalBar {
				$0.layout {
					$0.width == 70
					$0.height == 2
				}
				$0.relativeWidth = 1.0
				
				
			}
		}
	}
}