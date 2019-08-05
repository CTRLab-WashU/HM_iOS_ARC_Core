//
//  ACHomeView.swift
//  Arc
//
//  Created by Philip Hayes on 7/1/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
import HMMarkup
public protocol ACHomeViewDelegate : class{
	func beginPressed()
}
public class ACHomeView: ACTemplateView {
	public weak var delegate:ACHomeViewDelegate?
	public var heading:String? {
		get {
			return headingLabel.text
		}
		set {
			headingLabel.text = newValue

		}
	}
	public var message:String? {
		get {
			return messageLabel.text
		}
		set {
			messageLabel.text = newValue
			

		}
	}
	
	public var version:String? {
		get {
			return versionLabel.text
		}
		set {
			versionLabel.text = newValue
			
		}
	}
	
	var headingLabel: UILabel!
	var messageLabel: UILabel!
	
	public var debugButton: UIButton!
	public var surveyButton: UIButton!
	var relSeparatorWidth:CGFloat = 0.15
	var versionLabel: UILabel!
	public var separator:ACHorizontalBar!
	public var tutorialTarget:UIView?
//	var tutorialAnimation:Animate = Animate().
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	public override init() {
		super.init()
        debugButton.isHidden = (Arc.environment?.isDebug ?? false) == false
		separator.setNeedsDisplay()
	}
	public override func didMoveToWindow() {
		separator.relativeWidth = 0.15
		

	}
	public func highlightTutorialTargets() {
//		 tutorialTarget?.highlight()
//		window?.overlayView(view: self, withShapes: [.roundedRect(tutorialTarget!, 8.0)])
	}
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	override public func content(_ view: UIView) {
		let relWidth = relSeparatorWidth
		
			self.tutorialTarget = view.stack { [weak self] in
				$0.spacing = 20
				$0.axis = .vertical
				$0.distribution = .fill
				self?.headingLabel = $0.acLabel {
					Roboto.Style.headingMedium($0)
				}
				self?.separator = $0.acHorizontalBar {
					$0.relativeWidth = relWidth
					$0.color = UIColor(named: "HorizontalSeparator")
					$0.layout {
						$0.height == 2 ~ 999
						
					}
				}
				self?.messageLabel = $0.acLabel {
					Roboto.Style.body($0)
				}
				self?.surveyButton = $0.acButton {
					$0.setTitle("BEGIN".localized("button_begin"), for: .normal)
					$0.addAction {
						[weak self] in
						self?.delegate?.beginPressed()
					}
				}
			}
			
			
			self.debugButton = view.acButton {
				$0.setTitle("DEBUG", for: .normal)
				$0.addAction {
					Arc.shared.debugSchedule()
				}

			}
			view.view {
				$0.setContentHuggingPriority(.defaultLow, for: .vertical)
			}
		
			
			
	
	}
	public func setState(surveyStatus:SurveyAvailabilityStatus) {
		surveyButton.isHidden = true
		
		// Do any additional setup after loading the view.
		switch surveyStatus {
		case .available:
			heading = "Hello!".localized("home_header")
			message = "You have a new test available.".localized("home_body")
			surveyButton.isHidden = false
			
		case .laterToday:
			heading = "There are no tests to take right now.".localized("home_header2")
			message = "You will receive a notification later today when it's time to take your next test.".localized("home_body2")
			
		case .later(let date, let endDate):
			heading = "There are no tests available right now.".localized("home_header4")
			
			message = "Your next testing cycle will be *{DATE1}* through *{DATE2}*.".localized("home_body4")
				.replacingOccurrences(of: "{DATE1}", with: date)
				.replacingOccurrences(of: "{DATE2}", with: endDate)
			
		case .tomorrow:
			heading = "You're done with today's tests.".localized("home_header3")
			message = "We'll notify you tomorrow with your next test.".localized("home_body3")
			
		case .startingTomorrow(let date):
			
			heading = "Your next testing cycle starts tomorrow and runs through \(date).\n".localized("home_header6")
				.replacingOccurrences(of: "{DATE}", with: date)
			
			message = "We'll notify you when it's time to take a test.".localized("home_body_4_6")
			
		case .finished:
			heading = "You've finished the study!".localized("home_header5")
			message = "There are no more tests to take.".localized("home_body5")
		}
		
		
	}
}
