//
//  ACProgressView.swift
//  Arc
//
//  Created by Philip Hayes on 7/24/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
class ACProgressView: ACTemplateView {

	override func content(_ view: UIView) {
		if let v = view as? UIStackView {
			v.layoutMargins = .zero
		}
		view.stack {
			$0.axis = .vertical
			$0.isLayoutMarginsRelativeArrangement = true
			$0.layoutMargins = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
			$0.view {
				
				//Top section
				$0.backgroundColor = .white
				$0.stack {
					$0.isLayoutMarginsRelativeArrangement = true
					$0.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
					$0.attachTo(view: $0.superview)
					$0.axis = .vertical
					$0.alignment = .fill
					$0.spacing = 20
					
					$0.acLabel {
						Roboto.Style.heading($0, color: .black)
						$0.text = "Today's Sessions".localized("progress_daily_header")
						
					}
					
					$0.acHorizontalBar {
						$0.relativeWidth = 0.15
						$0.color = UIColor(named: "HorizontalSeparator")
						$0.layout {
							$0.height == 2 ~ 999
							
						}
					}
					
					$0.stack {
						$0.axis = .horizontal
						$0.distribution = .fillEqually
						$0.spacing = 8
						$0.layout {
							$0.height == 64 ~ 999
						}
						let config = CircularProgressView.Config(strokeWidth: 6,
																 trackColor: #colorLiteral(red: 0.400000006, green: 0.7799999714, blue: 0.7799999714, alpha: 1),
																 barColor: #colorLiteral(red: 0.04300000146, green: 0.1220000014, blue: 0.3330000043, alpha: 1))
						
						for _ in 0 ... 3 {
							$0.circularProgress {
								$0.config = config
								$0.progress = 0.5
							}
						}
						
						
						
						
					}
					
					$0.acLabel {
						Roboto.Style.body($0, color: #colorLiteral(red: 0.04300000146, green: 0.1220000014, blue: 0.3330000043, alpha: 1))

						$0.text = "*2* Complete | *1* Remaining"
					}
				}
			}
			$0.view {
				
				//This Week
				$0.backgroundColor = UIColor(named: "Progress Week")
				$0.stack {
					
					$0.attachTo(view: $0.superview)
					$0.axis = .vertical
					$0.alignment = .fill
					$0.spacing = 20
					$0.isLayoutMarginsRelativeArrangement = true
					$0.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
					$0.acLabel {
						Roboto.Style.heading($0, color: .black)
						$0.text = "This Week".localized("progress_weekly_header")
						
					}
					
					$0.acHorizontalBar {
						$0.relativeWidth = 0.15
						$0.color = UIColor(named: "HorizontalSeparator")
						$0.layout {
							$0.height == 2 ~ 999
							
						}
					}
					
					$0.acLabel {
						Roboto.Style.subHeading($0)
						$0.text = "Day *6* of *7*".localized("progess_weeklystatus")
					}
					
					
					
					
					$0.stepperProgress {
						
						$0.config.foregroundColor = #colorLiteral(red: 0, green: 0.3729999959, blue: 0.5220000148, alpha: 1)
						$0.config.endRadius = 25

						$0.layout {
							$0.height == 50 ~ 999
						}
					}
					
					
				}
			}
		}
	}
}
