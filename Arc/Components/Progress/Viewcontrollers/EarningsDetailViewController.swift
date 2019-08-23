//
//  EarningsDetailViewController.swift
//  Arc
//
//  Created by Philip Hayes on 8/22/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation
import ArcUIKit

open class EarningsDetailViewController : CustomViewController<ACEarningsDetailView> {
	
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
			let backButton = UIButton(type: .custom)
			backButton.frame = CGRect(x: 0, y: 0, width: 80, height: 32)
			backButton.setImage(UIImage(named: "cut-ups/icons/arrow_left_white"), for: .normal)
			backButton.setTitle("BACK".localized("button_back"), for: .normal)
			backButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 14)
			backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
			//backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
			backButton.setTitleColor(UIColor(named: "Secondary"), for: .normal)
			backButton.backgroundColor = UIColor(named:"Secondary Back Button Background")
			backButton.layer.cornerRadius = 16.0
			backButton.addTarget(self, action: #selector(self.backPressed), for: .touchUpInside)
			//NSLayoutConstraint(item: backButton, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: super.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: -75).isActive = true
			let leftButton = UIBarButtonItem(customView: backButton)
			
			//self.navigationItem.setLeftBarButton(leftButton, animated: true)
			self.navigationItem.leftBarButtonItem = leftButton
		
		
		customView.root.refreshControl = UIRefreshControl()
		customView.root.addSubview(customView.root.refreshControl!)
		customView.root.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)

		customView.root.alwaysBounceVertical = true
		
		NotificationCenter.default.addObserver(self, selector: #selector(didSynch(notification:)), name: .ACEarningDetailsUpdated, object: nil)
		didSynch(notification:  nil)
		
	}
	
	open override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	@objc func refresh(sender:AnyObject)
	{
		
		//my refresh code here..
		print("refreshing")
		
		customView.root.refreshControl?.endRefreshing()
	}
	@objc func backPressed()
	{
		
		self.navigationController?.popViewController(animated: true)
		
	}
	@objc func didSynch(notification:Notification?) {
		OperationQueue.main.addOperation { [weak self] in
			
			guard let weakSelf = self else{
				return
			}
			if let fetchDate = weakSelf.app.appController.lastFetched[EarningsController.detailKey] {
				weakSelf.customView.set(synched: fetchDate)
			}
			if let details:EarningDetail = weakSelf.app.appController.read(key: EarningsController.detailKey),
				let earnings = details.response?.earnings{
				weakSelf.customView.clear()
				weakSelf.update(earnings)
			}
		}
		
		
	}
	
	func update(_ earnings:EarningDetail.Response.Earnings) {
		let fetchDate = app.appController.lastFetched[EarningsController.detailKey]
		
		customView.set(studyTotal: earnings.total_earnings)
		if let date = fetchDate {
			customView.set(synched: date)
		}
		guard let cycles = earnings.cycles else {
			return
		}
		for cycle in cycles {
			
			customView.add(cycle: cycle)
		}
	}
	
}
