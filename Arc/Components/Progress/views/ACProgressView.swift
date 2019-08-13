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
	private var startDay:Date?
	override func content(_ view: UIView) {
		if let v = view as? UIStackView {
			v.layoutMargins = .zero
		}
		view.stack {
			let stack = $0
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
						Roboto.Style.headingMedium($0, color: .black)
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
						var config = Drawing.CircularBar()
						
						config.strokeWidth =  6
						config.trackColor = #colorLiteral(red: 0.400000006, green: 0.7799999714, blue: 0.7799999714, alpha: 1)
						config.barColor = #colorLiteral(red: 0.04300000146, green: 0.1220000014, blue: 0.3330000043, alpha: 1)
						
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
						Roboto.Style.headingMedium($0, color: .black)
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
					

					$0.weekStepperProgress {
						$0.set(step: 0, of: ["S", "M", "T", "W", "T", "F", "S"])
					}
					
					$0.stack {
						$0.axis = .vertical
						$0.spacing = 8.0
						$0.acLabel {
							Roboto.Style.body($0, color: ACColor.primary)
							$0.text = "".localized(ACTranslationKey.progress_startdate)
							
						}
						$0.acLabel {
							Roboto.Style.body($0)
							$0.text = Date().localizedFormat(template: ACDateStyle.longWeekdayMonthDay.rawValue,
															 options: 0,
															 locale: nil)
						}
					}
					
					$0.stack {
						$0.axis = .vertical
						$0.spacing = 8.0

						
						$0.acLabel {
							Roboto.Style.body($0, color: ACColor.primary)
							$0.text = "".localized(ACTranslationKey.progress_enddate)
						}
						$0.acLabel {
							Roboto.Style.body($0)
							$0.text = Date().addingDays(days: 6).localizedFormat(template: ACDateStyle.longWeekdayMonthDay.rawValue,
																				 options: 0,
																				 locale: nil)
						}
					}
					
				}
			}
			$0.view {
				
				//This Week
				$0.backgroundColor = ACColor.primaryInfo
				$0.stack {
					
					$0.attachTo(view: $0.superview)
					$0.axis = .vertical
					$0.alignment = .fill
					$0.spacing = 20
					$0.isLayoutMarginsRelativeArrangement = true
					$0.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
					$0.acLabel {
						Roboto.Style.headingMedium($0, color: .white)
						$0.text = "This Week".localized("progress_weekly_header")
						
					}
					
					$0.acHorizontalBar {
						$0.relativeWidth = 0.15
						$0.color = UIColor(named: "HorizontalSeparator")
						$0.layout {
							$0.height == 2 ~ 999
							
						}
					}
					
					$0.stack {
						$0.acLabel {
							Roboto.Style.subHeading($0, color: .white)
							$0.text = "Day *6* of *7*".localized(ACTranslationKey.progress_studystatus)
						}
					}
					
					
					
					$0.weekStepperProgress {
						$0.set(step: 0, of: ["S", "M", "T", "W", "T", "F", "S"])
					}
					
					$0.stack {
						$0.axis = .vertical
						$0.spacing = 8.0
						$0.acLabel {
							Roboto.Style.body($0, color: ACColor.highlight)
							$0.text = "".localized(ACTranslationKey.progress_joindate)
							
						}
						$0.acLabel {
							Roboto.Style.body($0, color: .white)
							$0.text = Date().localizedFormat(template: ACDateStyle.longWeekdayMonthDay.rawValue,
															 options: 0,
															 locale: nil)
						}
					}
					
					$0.stack {
						$0.axis = .vertical
						$0.alignment = .leading
						$0.spacing = 8.0
						
						$0.stack {
							$0.axis = .horizontal
							$0.distribution = .equalSpacing
							$0.acLabel {
								Roboto.Style.body($0, color: ACColor.highlight)
								$0.text = "".localized(ACTranslationKey.progess_finishdate)
								$0.numberOfLines = 1

							}
							$0.acLabel {
								Roboto.Style.body($0, color: ACColor.badgeBackground)
								$0.text = "".localized(ACTranslationKey.footnote_symbol)
								$0.numberOfLines = 1
							}
						}
						$0.acLabel {
							Roboto.Style.body($0, color:.white)
							$0.text = Date().addingDays(days: 6).localizedFormat(template: ACDateStyle.longWeekdayMonthDay.rawValue,
																				 options: 0,
																				 locale: nil)
						}
					}
					
					$0.stack {
						$0.axis = .vertical
						$0.spacing = 8.0
						
						
						$0.acLabel {
							Roboto.Style.body($0, color: ACColor.highlight)
							$0.text = "".localized(ACTranslationKey.progress_timebtwtesting)
						}
						$0.acLabel {
							
							var components = DateComponents()
							var calendar = Calendar.current
							calendar.locale = Locale(identifier: Arc.shared.appController.locale.string)
							components.month = 3
							
							DateComponentsFormatter.localizedString(from: components, unitsStyle: DateComponentsFormatter.UnitsStyle.full)
							Roboto.Style.body($0, color:.white)
							$0.text = Date().addingDays(days: 6).localizedFormat(template: ACDateStyle.longWeekdayMonthDay.rawValue,
																				 options: 0,
																				 locale: nil)
						}
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
