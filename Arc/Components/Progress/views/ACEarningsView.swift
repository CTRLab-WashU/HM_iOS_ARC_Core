//
//  ACEarningsView.swift
//  Arc
//
//  Created by Philip Hayes on 8/14/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation
import ArcUIKit
public class ACEarningsView : ACTemplateView {
	weak var headerLabel:ACLabel! //.earnings_body0
	var thisWeeksEarningsLabel:ACLabel!
	var thisStudysEarningsLabel:ACLabel!
	var lastSyncedLabel:ACLabel!
	var viewDetailsButton:ACButton!
	weak var earningsBodyLabel:ACLabel! //.earnings_body0 || .earnings_body1
	weak var syncLabel:ACLabel!
	weak var bonusGoalsSection:UIView!
	weak var bonusGoalsBodyLabel:ACLabel!
	weak var fourofFourGoal:FourOfFourGoalView!
	weak var twoADayGoal:TwoADayGoalView!
	weak var totalSessionsGoal:TotalSessionGoalView!
	public override func content(_ view: UIView) {
		if let v = view as? UIStackView {
			v.layoutMargins = .zero
		}
		view.stack { [unowned self] in
			$0.axis = .vertical
			$0.isLayoutMarginsRelativeArrangement = true
			$0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
			
			//MARK: Earnings Header
			$0.view {
				
				//Earnings
				$0.backgroundColor = ACColor.primaryInfo
				$0.stack {
					
					$0.attachTo(view: $0.superview)
					$0.axis = .vertical
					$0.alignment = .fill
					$0.spacing = 20
					$0.isLayoutMarginsRelativeArrangement = true
					$0.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 48, right: 24)
					self.headerLabel = $0.acLabel {
						Roboto.Style.headingMedium($0, color: .white)
						$0.text = "Earnings".localized(ACTranslationKey.faq_earnings_header)
						
					}
					
					$0.acHorizontalBar {
						$0.relativeWidth = 0.15
						$0.color = UIColor(named: "HorizontalSeparator")
						$0.layout {
							$0.height == 2 ~ 999
							
						}
					}
					$0.stack {
						self.earningsBodyLabel = $0.acLabel {
							Roboto.Style.body($0, color: .white)
						}
					}
					$0.stack {
						$0.distribution = .fillEqually
						$0.stack {
							$0.axis = .vertical
							$0.alignment = .center
							$0.acLabel {
								$0.textAlignment = .center

								Roboto.Style.body($0, color:ACColor.highlight)
								$0.text = "".localized(ACTranslationKey.earnings_weektotal)
							}
							self.thisWeeksEarningsLabel = $0.acLabel {
								$0.textAlignment = .center

								Roboto.Style.earningsBold($0, color:.white)
								$0.text = "$0.00"
							}
						}
						$0.stack {
							$0.axis = .vertical
							$0.alignment = .center
							$0.acLabel {
								$0.textAlignment = .center
								
								Roboto.Style.body($0, color:ACColor.highlight)
								$0.text = "".localized(ACTranslationKey.earnings_weektotal)
							}
							self.thisStudysEarningsLabel = $0.acLabel {
								$0.textAlignment = .center
								
								Roboto.Style.earningsBold($0, color:.white)
								$0.text = "$0.00"
							}
						}
					}
				
					self.lastSyncedLabel = $0.acLabel {
						$0.textAlignment = .center

						Roboto.Style.subBody($0, color:UIColor(red:0.71, green:0.73, blue:0.8, alpha:1))
						$0.text = "".localized(ACTranslationKey.earnings_sync)
					}
					
					self.viewDetailsButton = $0.acButton {
						$0.primaryColor = ACColor.secondary
						$0.secondaryColor = ACColor.secondaryGradient
						$0.setTitleColor(ACColor.badgeText, for: .normal)
						$0.setTitle("".localized(ACTranslationKey.button_viewdetails), for: .normal)
					}
				}
			}
			
			//MARK: Bonus Goal Header
			self.bonusGoalsSection = $0.view {
				
				//Bonus Goals
				$0.backgroundColor = .white
				$0.stack {
					
					$0.attachTo(view: $0.superview)
					$0.axis = .vertical
					$0.alignment = .fill
					$0.spacing = 20
					$0.isLayoutMarginsRelativeArrangement = true
					$0.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 48, right: 24)
					$0.acLabel {
						Roboto.Style.headingMedium($0, color: ACColor.badgeText)
						$0.text = "Bonus Goals".localized(ACTranslationKey.earnings_bonus_header)
						
					}
					
					$0.acHorizontalBar {
						$0.relativeWidth = 0.15
						$0.color = UIColor(named: "HorizontalSeparator")
						$0.layout {
							$0.height == 2 ~ 999
							
						}
					}
					$0.stack {
						self.bonusGoalsBodyLabel = $0.acLabel {
							Roboto.Style.body($0, color: ACColor.badgeText)
						}
					}
					
				}
			}

			//MARK: Bonus Goals Content
			$0.view { [unowned self] in
				
				//Bonus Goals
				$0.backgroundColor = ACColor.primaryInfo
				$0.stack {
					
					$0.attachTo(view: $0.superview)
					$0.axis = .vertical
					$0.alignment = .fill
					$0.spacing = 16
					$0.isLayoutMarginsRelativeArrangement = true
					$0.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 48, right: 8)
					
					
					self.fourofFourGoal = $0.fourOfFourGoalView {
						$0.set(titleText: "4 Out of 4")
						$0.set(isUnlocked: false)
						
					}
					
					//2 a day goal
					self.twoADayGoal = $0.twoADayGoalView {
						$0.set(titleText: "2-A-Day".localized(ACTranslationKey.earnings_2aday_header))
						$0.set(isUnlocked: false)
						
						
					}
					
					
					self.totalSessionsGoal = $0.totalSessionGoalView {
						$0.set(titleText: "21 Sessions".localized(ACTranslationKey.earnings_21tests_header))
						$0.set(isUnlocked: false)
						
					}
					$0.acButton {
						$0.primaryColor = ACColor.secondary
						$0.secondaryColor = ACColor.secondaryGradient
						$0.setTitleColor(ACColor.badgeText, for: .normal)
						$0.setTitle("".localized(ACTranslationKey.button_viewfaq), for: .normal)
					}
					
				}
			}
			
			
		}
	}
}
