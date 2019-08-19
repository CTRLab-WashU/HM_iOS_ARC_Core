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
	
	//Today section variables
	private var todaySection:UIView!
	private var headerLabel:ACLabel!
	private var progressViews:ACCircularProgressGroupStackView!
	private var progressViewStack:UIStackView!
	private var todaysSessionCompletionLabel:ACLabel!

	//This week section variables
	private var weekSection:UIView!
	private var weekHeaderLabel:ACLabel!
	private var weekProgressView:ACWeekStepperView!
	private var noticeLabel:ACLabel!
	private var dayOfWeekLabel:ACLabel!
	private var startDateLabel:ACLabel!
	private var endDateLabel:ACLabel!
	
	//This study section variables
	private var studySection:UIView!
	private var studyHeaderLabel:ACLabel!
	private var weekOfStudyLabel:ACLabel!
	private var blockProgressView:BlockProgressview!
	private var joinDateLabel:ACLabel!
	private var finishDateLabel:ACLabel!
	private var timeBetweenTestWeeksLabel:ACLabel!
	public var viewFaqButton:ACButton!
	override func content(_ view: UIView) {
		if let v = view as? UIStackView {
			v.layoutMargins = .zero
		}
		view.stack { [unowned self] in
			$0.axis = .vertical
			$0.isLayoutMarginsRelativeArrangement = true
			$0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
			self.todaySection = $0.view {
				
				//Top section
				$0.backgroundColor = .white
				$0.stack {
					$0.isLayoutMarginsRelativeArrangement = true
					$0.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
					$0.attachTo(view: $0.superview)
					$0.axis = .vertical
					$0.alignment = .fill
					$0.spacing = 20
					
					self.headerLabel = $0.acLabel {
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
					self.progressViews = $0.circularProgressGroup {
						$0.layout {
							$0.height == 64 ~ 999
						}
						$0.addProgressViews(count: 4)
						$0.set(progress: 0.9, for: 2)
					}
					
					
					self.todaysSessionCompletionLabel = $0.acLabel {
						Roboto.Style.body($0, color: #colorLiteral(red: 0.04300000146, green: 0.1220000014, blue: 0.3330000043, alpha: 1))

						$0.text = "*2* Complete | *1* Remaining"
					}
				}
			}
			self.weekSection =  $0.view {
				
				//This Week
				$0.backgroundColor = UIColor(named: "Progress Week")
				$0.stack {
					
					$0.attachTo(view: $0.superview)
					$0.axis = .vertical
					$0.alignment = .fill
					$0.spacing = 20
					$0.isLayoutMarginsRelativeArrangement = true
					$0.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
					
					
					self.weekHeaderLabel = $0.acLabel {
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
					
					self.dayOfWeekLabel = $0.acLabel {
						Roboto.Style.subHeading($0)
						$0.text = "Day *6* of *7*".localized("progess_weeklystatus")
					}
					

					self.weekProgressView = $0.weekStepperProgress {
						$0.set(step: 0, of: ["S", "M", "T", "W", "T", "F", "S"])
					}
					
					$0.stack {
						$0.axis = .vertical
						$0.spacing = 8.0
						$0.acLabel {
							Roboto.Style.body($0, color: ACColor.primary)
							$0.text = "".localized(ACTranslationKey.progress_startdate)
							
						}
						self.startDateLabel = $0.acLabel {
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
						self.endDateLabel = $0.acLabel {
							Roboto.Style.body($0)
							$0.text = Date().addingDays(days: 6).localizedFormat(template: ACDateStyle.longWeekdayMonthDay.rawValue,
																				 options: 0,
																				 locale: nil)
						}
					}
					
				}
			}
			self.studySection = $0.view {
				
				//This Study
				$0.backgroundColor = ACColor.primaryInfo
				$0.stack {
					
					$0.attachTo(view: $0.superview)
					$0.axis = .vertical
					$0.alignment = .fill
					$0.spacing = 20
					$0.isLayoutMarginsRelativeArrangement = true
					$0.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 48, right: 24)
					self.weekHeaderLabel = $0.acLabel {
						Roboto.Style.headingMedium($0, color: .white)
						$0.text = "This Study".localized(ACTranslationKey.progress_study_header)
						
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
					
					
					
					$0.blockProgress {
						$0.layout {
							$0.height == 42
						}
						$0.set(count: 12, current: 4)
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
					$0.stack {
						$0.axis = .horizontal
						$0.alignment = .top
						$0.acLabel {
							$0.layout {
								$0.width == 10
							}
							Roboto.Style.disclaimer($0, color: ACColor.badgeBackground)
							$0.text = "".localized(ACTranslationKey.footnote_symbol)
						}
						$0.acLabel {
							Roboto.Style.disclaimer($0, color: .white)
							$0.text = "".localized(ACTranslationKey.progress_studydisclaimer)
							
						}
						
					}
				}
			}
		}
	}
}
